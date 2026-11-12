class SessionsController < ApplicationController
  # パスワードの総当たりを防ぐ（3分間に10回まで）
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_path, alert: "試行回数が多すぎます。しばらく待ってからやり直してください" }

  def new
    redirect_to root_path if admin?
  end

  def create
    if self.class.valid_admin_password?(params[:password])
      reset_session # セッション固定攻撃の対策
      session[:admin] = true
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "パスワードが違います"
      render :new, status: 422
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ログアウトしました", status: :see_other
  end
end
