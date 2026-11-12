FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "記事 #{n}" }
    content { "# 見出し\n\n本文です。" }
  end
end
