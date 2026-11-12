require "rails_helper"

RSpec.describe Tag, type: :model do
  it "名前が無いと無効" do
    expect(Tag.new(tag_name: "")).not_to be_valid
  end

  it "同じ名前のタグは作れない" do
    create(:tag, tag_name: "Ruby")
    expect(Tag.new(tag_name: "Ruby")).not_to be_valid
  end

  it "バリデーションを通さない書き込みでも、DB の制約で重複は防がれる（大文字小文字の違いも同じ名前扱い）" do
    create(:tag, tag_name: "Ruby")
    expect {
      Tag.new(tag_name: "ruby").save(validate: false)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
