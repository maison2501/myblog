# リクエストスペックで管理者としてログインするためのヘルパー
module AdminLoginHelper
  TEST_ADMIN_PASSWORD = "test-admin-password".freeze

  def login_as_admin
    post login_path, params: { password: TEST_ADMIN_PASSWORD }
  end
end

RSpec.configure do |config|
  config.include AdminLoginHelper, type: :request

  config.around(:each, type: :request) do |example|
    original = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_PASSWORD"] = AdminLoginHelper::TEST_ADMIN_PASSWORD
    example.run
  ensure
    ENV["ADMIN_PASSWORD"] = original
  end
end
