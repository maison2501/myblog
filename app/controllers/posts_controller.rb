class PostsController < ApplicationController
  # 閲覧は誰でも、投稿・編集・削除・画像アップロードは管理者だけ
  before_action :require_admin, except: %i[ index show categories search ]
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    @posts = Post.recent
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

  # カテゴリー（タグ）一覧
  def categories
    @tags = Tag.order(:tag_name)
  end

  # 指定したタグが付いた記事の一覧
  def search
    @tag = Tag.find(params[:tag_id])
    @posts = @tag.posts.recent
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
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.expect(post: [ :title, :content, :tag_names ])
    end
end
