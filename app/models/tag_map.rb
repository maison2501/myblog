# 記事とタグの紐付け（belongs_to なので post と tag の存在は自動で検証される）
class TagMap < ApplicationRecord
  belongs_to :post
  belongs_to :tag
end
