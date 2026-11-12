FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "記事 #{n}" }
    content { "# 見出し\n\n本文です。" }
    published_at { 1.hour.ago }

    trait :draft do
      published_at { nil }
    end
  end
end
