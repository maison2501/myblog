FROM mysql:8.0

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen ja_JP.UTF-8

RUN sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen && locale-gen

ENV LANG ja_JP.UTF-8
ENV TZ Asia/Tokyo