require "rails_helper"

RSpec.describe Tag, type: :model do
  it "名前が無いと無効" do
    expect(Tag.new(tag_name: "")).not_to be_valid
  end

  it "同じ名前のタグは作れない" do
    create(:tag, tag_name: "Ruby")
    expect(Tag.new(tag_name: "Ruby")).not_to be_valid
  end
end
