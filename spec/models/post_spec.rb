require "rails_helper"

RSpec.describe Post, type: :model do
  describe "バリデーション" do
    it "タイトルと本文があれば有効" do
      expect(build(:post)).to be_valid
    end

    it "タイトルが無いと無効" do
      expect(build(:post, title: "")).not_to be_valid
    end

    it "本文が無いと無効" do
      expect(build(:post, content: "")).not_to be_valid
    end

    it "エラーメッセージは日本語" do
      post = Post.new
      post.valid?
      expect(post.errors.full_messages).to include("タイトルを入力してください", "本文を入力してください")
    end
  end

  describe "#tag_names=" do
    it "カンマ区切りの文字列からタグを付ける（前後の空白・空欄・重複は無視）" do
      post = create(:post, tag_names: " Ruby, 猫,, Ruby ,海")
      expect(post.reload.tags.map(&:tag_name)).to contain_exactly("Ruby", "猫", "海")
    end

    it "読点（、）でも区切れる" do
      post = create(:post, tag_names: "猫、海")
      expect(post.reload.tags.map(&:tag_name)).to contain_exactly("猫", "海")
    end

    it "既存のタグは使い回し、外したタグは記事との紐付けだけ消す" do
      ruby = create(:tag, tag_name: "Ruby")
      post = create(:post, tag_names: "Ruby,猫")

      expect { post.update!(tag_names: "Ruby,海") }.to change(Tag, :count).by(1)
      expect(post.reload.tags.map(&:tag_name)).to contain_exactly("Ruby", "海")
      expect(post.tags).to include(ruby)
      expect(Tag.exists?(tag_name: "猫")).to be true
    end

    it "タグ欄を送らなければ、タグは変わらない" do
      post = create(:post, tag_names: "Ruby")
      post.update!(title: "新しいタイトル")
      expect(post.reload.tags.map(&:tag_name)).to eq [ "Ruby" ]
    end
  end

  describe "下書き / 公開" do
    it "公開日時が無ければ下書き" do
      post = build(:post, :draft)
      expect(post).to be_draft
      expect(post).not_to be_published
    end

    it "published は公開日時が今より前の記事だけ（下書きと、公開日時が未来の記事は含まない）" do
      published = create(:post, published_at: 1.day.ago)
      create(:post, :draft)
      create(:post, published_at: 1.day.from_now)
      expect(Post.published).to eq [ published ]
    end

    it "「公開する」にチェックすると公開日時が入り、外すと下書きに戻る" do
      post = create(:post, :draft)
      post.update!(publish: "1")
      expect(post.published_at).to be_present

      post.update!(publish: "0")
      expect(post.published_at).to be_nil
    end

    it "公開済みの記事を編集しても、公開日時は変わらない" do
      post = create(:post, published_at: 3.days.ago)
      expect { post.update!(title: "直した", publish: "1") }.not_to change { post.reload.published_at }
    end

    it "公開日時を未来にして「公開する」と予約投稿になり、その時刻を過ぎると公開される" do
      post = create(:post, :draft)
      post.update!(publish: "1", published_at: 1.day.from_now)
      expect(post).to be_scheduled
      expect(Post.published).not_to include(post)

      travel 2.days do
        expect(post).to be_published
        expect(Post.published).to include(post)
      end
    end

    it "公開日時を入れても「公開する」にチェックしなければ下書き" do
      post = create(:post, :draft)
      post.update!(publish: "0", published_at: 1.day.from_now)
      expect(post).to be_draft
    end

    it "recent は新しい順（下書きは作成日時で並ぶ）" do
      old = create(:post, published_at: 2.days.ago)
      new = create(:post, published_at: 1.day.ago)
      draft = create(:post, :draft)
      expect(Post.recent).to eq [ draft, new, old ]
    end
  end

  describe "#tag_names" do
    it "付いているタグをカンマ区切りで返す" do
      post = create(:post, tag_names: "Ruby,猫")
      expect(post.reload.tag_names.split(",")).to contain_exactly("Ruby", "猫")
    end
  end
end
