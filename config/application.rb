require_relative "boot"

require "rails"
# 使う機能だけ読み込む（rails/all だとメール送受信・ActionText・WebSocket なども全部読み込まれる）
require "active_model/railtie"
require "active_job/railtie"      # ActiveStorage が画像の解析に使う
require "active_record/railtie"
require "active_storage/engine"   # 記事に貼る画像のアップロード
require "action_controller/railtie"
require "action_view/railtie"
# 使っていないので読み込まないもの:
# require "action_mailer/railtie"   # メール送信
# require "action_mailbox/engine"   # メール受信
# require "action_text/engine"      # リッチテキストエディタ（Trix）
# require "action_cable/engine"     # WebSocket
# require "rails/test_unit/railtie" # テストは RSpec を使う

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 8.1

    # lib/ 配下を自動読み込みの対象にする（assets と tasks は除く）
    config.autoload_lib(ignore: %w[assets tasks])

    # 画面に表示する日時を日本時間にする（DB には UTC のまま保存される）
    config.time_zone = "Tokyo"

    # 画面の文言（日付の書式やエラーメッセージ）は日本語（config/locales/ja.yml）
    config.i18n.default_locale = :ja
    config.i18n.available_locales = %i[ ja en ]
  end
end
