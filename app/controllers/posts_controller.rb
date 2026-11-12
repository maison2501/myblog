class PostsController < ApplicationController
  PER_PAGE = 10

  # 閲覧は誰でも、投稿・編集・削除・画像アップロードは管理者だけ
  before_action :require_admin, except: %i[ index show categories search ]
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    paginate visible_posts.recent
  end

  def show
  end

  def new
    @post = Post.new
  end

  def edit
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post, notice: "記事を投稿しました"
    else
      render :new, status: 422
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "記事を更新しました"
    else
      render :edit, status: 422
    end
  end

  def destroy
    @post.destroy!
    redirect_to posts_path, notice: "記事を削除しました", status: :see_other
  end

  # カテゴリー（タグ）一覧。見られる記事が1つも無いタグは出さない
  def categories
    @tags = Tag.joins(:posts).merge(visible_posts).distinct.order(:tag_name)
  end

  # 指定したタグが付いた記事の一覧
  def search
    @tag = Tag.find(params[:tag_id])
    paginate @tag.posts.merge(visible_posts).recent
  end

  # エディタからの画像アップロード。保存した画像のパス（/rails/active_storage/...）を返す
  # ドメインを含めないので、公開先の URL が変わっても記事内の画像は表示される
  def attach
    attachment = Attachment.new(image: params[:image])

    if attachment.save
      render json: { url: rails_blob_path(attachment.image, only_path: true) }
    else
      render json: { errors: attachment.errors.full_messages }, status: 422
    end
  end

  private
    # 管理者には下書きも含めた全記事、それ以外の人には公開済みの記事だけを見せる
    def visible_posts
      admin? ? Post.all : Post.published
    end

    # 下書きの記事を管理者以外が開くと 404（「存在しない」扱い）になる
    def set_post
      @post = visible_posts.find(params[:id])
    end

    # 1ページ PER_PAGE 件ずつ表示する。
    # 1件多く取ってきて、あふれたら「次のページがある」と判断する（全件数を数える SQL が要らない）
    def paginate(posts)
      @page = [ params[:page].to_i, 1 ].max
      records = posts.offset((@page - 1) * PER_PAGE).limit(PER_PAGE + 1).to_a
      @next_page = @page + 1 if records.size > PER_PAGE
      @prev_page = @page - 1 if @page > 1
      @posts = records.first(PER_PAGE)
    end

    def post_params
      params.expect(post: [ :title, :content, :tag_names, :publish ])
    end
end
