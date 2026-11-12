require "rails_helper"

RSpec.describe "下書き・ページ送り・フィード・OGP", type: :request do
  describe "下書き" do
    let!(:published) { create(:post, title: "公開した記事", tag_names: "猫") }
    let!(:draft) { create(:post, :draft, title: "書きかけの記事", tag_names: "猫, 下書きだけのタグ") }

    context "未ログイン" do
      it "一覧・タグ別一覧に下書きは出ない" do
        get root_path
        expect(response.body).to include("公開した記事")
        expect(response.body).not_to include("書きかけの記事")

        get tag_posts_path(Tag.find_by!(tag_name: "猫"))
        expect(response.body).not_to include("書きかけの記事")
      end

      it "下書きの記事ページは 404" do
        get post_path(draft)
        expect(response).to have_http_status(:not_found)
      end

      it "下書きにしか付いていないタグはカテゴリー一覧に出ない" do
        get categories_path
        expect(response.body).to include("猫")
        expect(response.body).not_to include("下書きだけのタグ")
      end
    end

    context "管理者" do
      before { login_as_admin }

      it "下書きも一覧に出て、「下書き」と表示される" do
        get root_path
        expect(response.body).to include("書きかけの記事", "下書き")
      end

      it "下書きの記事ページを開ける" do
        get post_path(draft)
        expect(response).to have_http_status(:ok)
      end

      it "「公開する」にチェックして投稿すると公開される" do
        post posts_path, params: { post: { title: "今すぐ公開", content: "本文", publish: "1" } }
        expect(Post.find_by!(title: "今すぐ公開")).to be_published
      end

      it "チェックしないで投稿すると下書きになる" do
        post posts_path, params: { post: { title: "あとで公開", content: "本文", publish: "0" } }
        expect(Post.find_by!(title: "あとで公開")).to be_draft
      end
    end
  end

  describe "ページ送り" do
    before do
      12.times { |i| create(:post, title: "連番記事#{i + 1}", published_at: (12 - i).hours.ago) }
    end

    it "1ページ目は新しい10件と「古い記事」へのリンク" do
      get root_path
      expect(response.body).to include("連番記事12", "連番記事3")
      expect(response.body).not_to include("連番記事2<")
      expect(response.body).to include("古い記事")
      expect(response.body).not_to include("新しい記事")
    end

    it "2ページ目は残りの2件と「新しい記事」へのリンク" do
      get root_path(page: 2)
      expect(response.body).to include("連番記事2<", "連番記事1<")
      expect(response.body).not_to include("連番記事3<")
      expect(response.body).to include("新しい記事")
      expect(response.body).not_to include("古い記事")
    end
  end

  describe "フィード" do
    it "公開済みの記事だけが Atom 形式で出る" do
      create(:post, title: "フィードに出る記事")
      create(:post, :draft, title: "フィードに出ない記事")

      get feed_path
      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq "application/atom+xml"
      expect(response.body).to include("フィードに出る記事")
      expect(response.body).not_to include("フィードに出ない記事")
    end

    it "どのページにもフィードの場所が書かれている" do
      get root_path
      expect(response.body).to include('type="application/atom+xml"')
    end
  end

  describe "OGP" do
    it "記事ページには記事のタイトルと書き出しが入る" do
      post = create(:post, title: "海の話", content: "## 見出し\n\n今日は **海** に行った。")
      get post_path(post)
      expect(response.body).to include('property="og:title" content="海の話 - Blog Maison"')
      expect(response.body).to include('property="og:description" content="見出し 今日は 海 に行った。"')
      expect(response.body).to include('property="og:type" content="article"')
    end
  end
end
