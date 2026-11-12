class Post < ApplicationRecord
  has_many :tag_maps, dependent: :destroy
  has_many :tags, through: :tag_maps

  validates :title, presence: true
  validates :content, presence: true

  scope :recent, -> { order(created_at: :desc) }

  after_save :sync_tags, if: -> { @pending_tag_names }

  # フォームの「タグ」欄（カンマ区切りの文字列）として読み書きする
  def tag_names
    (@pending_tag_names || tags.map(&:tag_name)).join(",")
  end

  def tag_names=(value)
    @pending_tag_names = value.to_s.split(/[,、]/).map(&:strip).compact_blank.uniq
  end

  private
    # 入力されたタグに付け替える。無いタグは作成し、外したタグは記事との紐付けだけ消す
    def sync_tags
      self.tags = @pending_tag_names.map { |name| Tag.find_or_create_by!(tag_name: name) }
      @pending_tag_names = nil
    end
end
