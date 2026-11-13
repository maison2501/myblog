require "rouge/plugins/redcarpet"

module ApplicationHelper
  SITE_TITLE = "Blog Maison".freeze

  def site_title
    SITE_TITLE
  end

  # <title> に使う。ページ名があれば「ページ名 - Blog Maison」
  def full_title(page_title)
    page_title.blank? ? SITE_TITLE : "#{page_title} - #{SITE_TITLE}"
  end

  # 記事ページの見出しの下に出す日付・状態
  def post_status_text(post)
    if post.draft?
      "下書き（あなたにしか見えていません）"
    elsif post.scheduled?
      "#{l(post.published_at, format: :long)} に公開予定（予約投稿）"
    else
      l(post.published_at, format: :long)
    end
  end

  # 記事の書き出し（Markdown の記号を除いた本文の先頭）。OGP やフィードの説明文に使う
  def post_excerpt(post, length: 120)
    strip_tags(markdown(post.content)).squish.truncate(length)
  end

  # フィード用の本文 HTML。記事内の画像やリンクは "/rails/active_storage/..." のようなドメインなしのパスなので、
  # フィードリーダー（別のサイト上で表示される）でも辿れるよう、先頭にこのブログの URL を付ける
  def feed_html(post, base_url: request.base_url)
    fragment = Nokogiri::HTML5.fragment(markdown(post.content))
    fragment.css("img[src], a[href]").each do |node|
      attr = node.name == "img" ? "src" : "href"
      path = node[attr]
      node[attr] = base_url + path if path.start_with?("/") && !path.start_with?("//")
    end
    fragment.to_html
  end

  # Markdown を HTML に変換する。```ruby のようなコードブロックは Rouge で色付けする
  # （Redcarpet の変換器はスレッドセーフではないので、呼び出しごとに作る）
  def markdown(text)
    Redcarpet::Markdown.new(MarkdownRenderer.new(**MARKDOWN_RENDER_OPTIONS), **MARKDOWN_EXTENSIONS)
                       .render(text.to_s)
                       .html_safe
  end

  class MarkdownRenderer < Redcarpet::Render::HTML
    include Rouge::Plugins::Redcarpet
  end

  MARKDOWN_RENDER_OPTIONS = {
    filter_html: true,     # 本文中の生の HTML は出力しない
    safe_links_only: true, # javascript: などの危険なリンクは出力しない
    hard_wrap: true        # 改行をそのまま <br> にする
  }.freeze

  MARKDOWN_EXTENSIONS = {
    autolink: true,                     # URL を自動でリンクにする
    no_intra_emphasis: true,            # 単語の途中の _ や * を強調として扱わない
    fenced_code_blocks: true,           # ``` で囲んだコードブロック
    disable_indented_code_blocks: true, # 行頭スペース4つのコードブロックは使わない
    lax_spacing: true,                  # HTML ブロックの前後に空行が無くてもよい
    strikethrough: true,                # ~~取り消し線~~
    superscript: true,                  # ^上付き
    tables: true,                       # 表
    underline: true,                    # _下線_
    highlight: true,                    # ==ハイライト==
    quote: true,                        # "引用"
    footnotes: true                     # 脚注 [^1]
  }.freeze
end
