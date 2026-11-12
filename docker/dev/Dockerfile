# 開発用イメージ（compose.yaml の app サービスが使う）
# ソースコードは実行時にマウントするので、ここでは gem のインストールまでを済ませておく
FROM ruby:3.4

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# DB に接続する mysql コマンド（bin/rails dbconsole 用）
# mysql2 gem のビルドに必要なライブラリは ruby:3.4 イメージに最初から入っている
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gemfile が変わらない限り、この層はキャッシュが効いて bundle install が再実行されない
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY docker/dev/entrypoint.sh /usr/bin/
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
