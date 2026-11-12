require_relative "boot"

require "rails/all"

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
  end
end
