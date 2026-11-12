require "rails_helper"

RSpec.describe "管理者ログイン", type: :request do
  it "正しいパスワードでログインできる" do
    login_as_admin
    expect(response).to redirect_to(root_path)

    get new_post_path
    expect(response).to have_http_status(:ok)
  end

  it "間違ったパスワードではログインできない" do
    post login_path, params: { password: "wrong" }
    expect(response).to have_http_status(422)

    get new_post_path
    expect(response).to redirect_to(login_path)
  end

  it "パスワードが未設定なら、空のパスワードでもログインできない" do
    ENV["ADMIN_PASSWORD"] = nil
    post login_path, params: { password: "" }
    expect(response).to have_http_status(422)
  end

  it "ログアウトすると編集できなくなる" do
    login_as_admin
    delete logout_path
    expect(response).to redirect_to(root_path)

    get new_post_path
    expect(response).to redirect_to(login_path)
  end
end
