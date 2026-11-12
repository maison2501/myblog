FROM ruby:3.4

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# mysql2 gem のビルドと DB 接続確認に必要なものだけ入れる
# （importmap を使うので Node.js / Yarn は不要）
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gemfile.lock がまだ無い場合もビルドできるように * を付けている
COPY Gemfile Gemfile.lock* /app/
RUN bundle install

COPY . /app

COPY docker/app/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
