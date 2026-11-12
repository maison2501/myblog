# スクリーンショット用のサンプル記事を作る
Post.destroy_all
Tag.destroy_all

Post.create!(
  title: "海辺で猫と過ごした週末",
  tag_names: "猫, 海",
  content: <<~MD
    ## 土曜日

    朝から **海** へ。猫は相変わらず ~~やる気がない~~ マイペース。

    > 波の音だけを聞いていた

    | 時間 | やったこと |
    |------|------------|
    | 9:00 | 散歩 |
    | 12:00 | 昼寝 |

    - 貝殻を拾った
    - 夕日を見た
  MD
)

Post.create!(
  title: "Rails 8 にアップデートした",
  tag_names: "Ruby, Rails",
  content: <<~MD
    放置していたブログを Rails 8.1 に上げた。

    ```ruby
    class Post < ApplicationRecord
      has_many :tags, through: :tag_maps
      scope :recent, -> { order(created_at: :desc) }

      def title_with_date
        "#{title} (#{created_at.to_date})" # コメント
      end
    end
    ```

    詳しくは https://rubyonrails.org を参照。
  MD
)

puts "seeded #{Post.count} posts, #{Tag.count} tags"
