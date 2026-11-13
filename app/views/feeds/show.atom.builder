# atom_feed は Rails に入っている Atom 用のヘルパー（builder でXMLを組み立てる）
atom_feed(language: "ja-JP", root_url: root_url) do |feed|
  feed.title site_title
  feed.updated(@posts.first&.published_at || Time.current)

  @posts.each do |post|
    feed.entry(post, published: post.published_at, updated: post.updated_at) do |entry|
      entry.title post.title
      entry.summary post_excerpt(post)
      entry.content feed_html(post), type: "html"
      entry.author { |author| author.name site_title }
    end
  end
end
