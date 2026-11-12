# syntax=docker/dockerfile:1
# 本番用イメージ（開発用は docker/dev/Dockerfile）
#
#   docker build -t myblog .
#   docker run -p 3000:3000 \
#     -e SECRET_KEY_BASE=... -e DATABASE_HOST=... -e APP_DATABASE_PASSWORD=... -e ADMIN_PASSWORD=... \
#     myblog
#
# マルチステージビルド: 「build」段階でコンパイラなどを使って gem とアセットを用意し、
# 最終イメージには実行に必要なものだけをコピーする。結果、イメージが小さく、攻撃面も狭くなる。

ARG RUBY_VERSION=3.4.10

# ---------- base: 実行時にも必要なもの ----------
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# curl はヘルスチェック用、default-mysql-client は mysql2 gem が実行時に使うライブラリを含む
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl default-mysql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    LANG="C.UTF-8" \
    TZ="Asia/Tokyo"

# ---------- build: gem のコンパイルとアセットの準備（最終イメージには残らない） ----------
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential default-libmysqlclient-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Gemfile が変わらない限り、bundle install の層はキャッシュが使われる
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

# 起動を速くするためのキャッシュと、指紋付きのアセット（public/assets）を作る
# アセットの作成に本物の秘密鍵は要らないので、ダミーで済ませる
RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ---------- 最終イメージ ----------
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# root ではなく専用ユーザーで動かす（万一アプリが乗っ取られても被害を小さくする）
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# 起動時に DB の作成・マイグレーションを済ませる（bin/docker-entrypoint）
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://localhost:3000/up || exit 1
CMD ["./bin/rails", "server"]
