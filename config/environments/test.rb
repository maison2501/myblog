require "active_support/core_ext/integer/time"

# テスト専用の環境。テスト用DBは毎回作り直されるので、データを置かないこと。
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?

  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # 例外は画面に描画せず、そのままテストに伝える（404 などは通常どおり描画）
  config.action_dispatch.show_exceptions = :rescuable

  config.action_controller.allow_forgery_protection = false

  config.active_storage.service = :test

  config.active_support.deprecation = :stderr
  config.action_controller.raise_on_missing_callback_actions = true
end
