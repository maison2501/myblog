class Post < ApplicationRecord
  has_many :tag_maps, dependent: :destroy
  has_many :tags, through: :tag_maps

  validates :title, presence: true
  validates :content, presence: true

  # 公開済み（公開日時が入っていて、それが今より前）の記事
  scope :published, -> { where(published_at: ..Time.current) }
  # 新しい順。下書きは公開日時が無いので作成日時で並べる
  scope :recent, -> { order(Arel.sql("COALESCE(posts.published_at, posts.created_at) DESC")) }

  # 「公開する」と「公開日時」はフォームから同時に届くので、両方そろってから保存の直前にまとめて反映する
  before_validation :apply_publish_request, unless: -> { @publish_requested.nil? }
  after_save :sync_tags, if: -> { @pending_tag_names }

  def draft?
    published_at.nil?
  end

  def published?
    published_at.present? && published_at <= Time.current
  end

  # 公開日時が未来に設定されている（予約投稿）
  def scheduled?
    published_at.present? && published_at > Time.current
  end

  # 一覧などに出す日付（公開日時があればそれ、下書きなら作成日時）
  def display_time
    published_at || created_at
  end

  # フォームの「公開する」チェックボックス用
  def publish
    @publish_requested.nil? ? published_at.present? : @publish_requested
  end

  def publish=(value)
    @publish_requested = ActiveModel::Type::Boolean.new.cast(value)
  end

  # フォームの「タグ」欄（カンマ区切りの文字列）として読み書きする
  def tag_names
    (@pending_tag_names || tags.map(&:tag_name)).join(",")
  end

  def tag_names=(value)
    @pending_tag_names = value.to_s.split(/[,、]/).map(&:strip).compact_blank.uniq
  end

  private
    # チェックあり: 公開日時が入っていればその日時（未来なら予約投稿）、空なら今すぐ公開
    # チェックなし: 下書き（公開日時を消す）
    def apply_publish_request
      self.published_at = @publish_requested ? (published_at || Time.current) : nil
      @publish_requested = nil
    end

    # 入力されたタグに付け替える。無いタグは作成し、外したタグは記事との紐付けだけ消す
    def sync_tags
      self.tags = @pending_tag_names.map { |name| Tag.find_or_create_by!(tag_name: name) }
      @pending_tag_names = nil
    end
end
