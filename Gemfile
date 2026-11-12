source "https://rubygems.org"

ruby "~> 3.4"

gem "rails", "~> 8.1.3"

# アセット配信とJavaScript（Rails 8 標準構成）
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

# データベースとWebサーバー
gem "mysql2", "~> 0.5"
gem "puma", ">= 6.0"

# 起動の高速化（config/boot.rb で読み込み）
gem "bootsnap", require: false

# Windows にはタイムゾーン情報がないため
gem "tzinfo-data", platforms: %i[ windows jruby ]

# テンプレート
gem "slim-rails"

# Markdown 表示とコードのシンタックスハイライト
gem "redcarpet", "~> 3.6"
gem "rouge"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  # コードの書き方のチェック（Rails 公式のルール。設定は .rubocop.yml）
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
end

group :development do
  gem "web-console"
end
