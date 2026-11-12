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

  describe "#tag_names" do
    it "付いているタグをカンマ区切りで返す" do
      post = create(:post, tag_names: "Ruby,猫")
      expect(post.reload.tag_names.split(",")).to contain_exactly("Ruby", "猫")
    end
  end
end
