class Tag < ApplicationRecord
  has_many :tag_maps, dependent: :destroy
  has_many :posts, through: :tag_maps

  validates :tag_name, presence: true, uniqueness: true
end
