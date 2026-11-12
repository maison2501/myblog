require "rails_helper"

RSpec.describe "記事", type: :request do
  let!(:blog_post) { create(:post, title: "猫と海", content: "```ruby\nputs 1\n```", tag_names: "猫") }

  describe "誰でも見られるページ" do
    it "記事一覧" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("猫と海")
    end

    it "記事ページ（Markdown とコードの色付けが効いている）" do
      get post_path(blog_post)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="highlight')
    end

    it "カテゴリー一覧とタグ別の記事一覧" do
      get categories_path
      expect(response).to have_http_status(:ok)

      get tag_posts_path(blog_post.tags.first)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("猫と海")
    end

    it "未ログインでは編集・削除ボタンが出ない" do
      get post_path(blog_post)
      expect(response.body).not_to include(edit_post_path(blog_post))
    end
  end

  describe "未ログインの場合" do
    it "投稿画面はログインページへ飛ばされる" do
      get new_post_path
      expect(response).to redirect_to(login_path)
    end

    it "投稿できない" do
      expect {
        post posts_path, params: { post: { title: "x", content: "y" } }
      }.not_to change(Post, :count)
    end

    it "更新できない" do
      patch post_path(blog_post), params: { post: { title: "書き換え" } }
      expect(blog_post.reload.title).to eq "猫と海"
    end

    it "削除できない" do
      expect { delete post_path(blog_post) }.not_to change(Post, :count)
    end

    it "画像をアップロードできない" do
      post attach_image_path, params: { image: fixture_file_upload("image.png", "image/png") },
                                 headers: { "Accept" => "application/json" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "管理者としてログインしている場合" do
    before { login_as_admin }

    it "投稿できる" do
      expect {
        post posts_path, params: { post: { title: "新しい記事", content: "本文", tag_names: "海" } }
      }.to change(Post, :count).by(1)
      expect(response).to redirect_to(post_path(Post.last))
    end

    it "入力が足りないと投稿できない" do
      post posts_path, params: { post: { title: "", content: "" } }
      expect(response).to have_http_status(422)
    end

    it "更新できる" do
      patch post_path(blog_post), params: { post: { title: "書き換え", content: "本文", tag_names: "猫,海" } }
      expect(blog_post.reload.title).to eq "書き換え"
      expect(blog_post.tags.map(&:tag_name)).to contain_exactly("猫", "海")
    end

    it "削除できる" do
      expect { delete post_path(blog_post) }.to change(Post, :count).by(-1)
    end

    it "画像をアップロードすると URL が返る" do
      post attach_image_path, params: { image: fixture_file_upload("image.png", "image/png") }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["url"]).to start_with("/rails/active_storage/")
    end
  end
end
