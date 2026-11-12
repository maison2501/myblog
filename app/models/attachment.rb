# 記事本文に貼り付ける画像
class Attachment < ApplicationRecord
  ACCEPTED_CONTENT_TYPES = %w[ image/png image/jpeg image/gif image/webp ].freeze
  MAX_SIZE = 10.megabytes

  has_one_attached :image

  validate :image_must_be_valid

  private
    def image_must_be_valid
      if !image.attached?
        errors.add(:image, "を選択してください")
      elsif !image.blob.content_type.in?(ACCEPTED_CONTENT_TYPES)
        errors.add(:image, "は PNG / JPEG / GIF / WebP のいずれかにしてください")
      elsif image.blob.byte_size > MAX_SIZE
        errors.add(:image, "は 10MB 以下にしてください")
      end
    end
end
