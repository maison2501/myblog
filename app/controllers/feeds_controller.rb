# 記事の更新情報（Atom フィード）。Feedly などのリーダーに /feed を登録すると、新しい記事が届く
class FeedsController < ApplicationController
  def show
    @posts = Post.published.recent.limit(20)
  end
end
