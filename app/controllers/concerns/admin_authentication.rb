# 管理者（ブログの持ち主）としてログインしているかを扱う
#
# パスワードは環境変数 ADMIN_PASSWORD か、credentials の admin_password に設定する。
# どちらも未設定のときは誰もログインできない（=投稿・編集できない）。
module AdminAuthentication
  extend ActiveSupport::Concern

  included do
    helper_method :admin?
  end

  class_methods do
    # 正しい管理者パスワードかどうか（文字列比較の時間差で推測されないよう secure_compare を使う）
    def valid_admin_password?(password)
      expected = ENV["ADMIN_PASSWORD"].presence || Rails.application.credentials.admin_password.presence
      return false if expected.blank? || password.blank?

      ActiveSupport::SecurityUtils.secure_compare(password.to_s, expected.to_s)
    end
  end

  private
    def admin?
      session[:admin] == true
    end

    def require_admin
      return if admin?

      respond_to do |format|
        format.html { redirect_to login_path, alert: "ログインしてください" }
        format.json { head :unauthorized }
      end
    end
end
