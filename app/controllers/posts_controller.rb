class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @tag_list = Tag.all                         #ビューでタグ一覧を表示するために全取得。
    @posts = Post.all.order(created_at: "desc") #ビューで投稿一覧を表示するために全取得。
  end

  # GET /posts/1 or /posts/1.json
  def show
    @post = Post.find(params[:id])  #クリックした投稿を取得。
    @post_tags = @post.tags         #そのクリックした投稿に紐付けられているタグの取得。
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @post = Post.find(params[:id])
    @tag_list = @post.tags.pluck(:tag_name).join(',')
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)
    tag_list = params[:post][:tag_name].split(',')
    respond_to do |format|
      if @post.save
        @post.save_posts(tag_list)
        format.html { redirect_to post_url(@post), notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    @post = Post.find(params[:id])
    tag_list = params[:post][:tag_name].split(',')
    respond_to do |format|
      if @post.update(post_params)
        @post.save_posts(tag_list)
        format.html { redirect_to post_url(@post), notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def categories
    @tag_list = Tag.all
  end

  def search
    @tag_list = Tag.all  #こっちの投稿一覧表示ページでも全てのタグを表示するために、タグを全取得
    @tag = Tag.find(params[:tag_id])  #クリックしたタグを取得
    @posts = @tag.posts.all.order(created_at: "desc")           #クリックしたタグに紐付けられた投稿を全て表示
  end

  def attach
    attachment = Attachment.create! image: params[:image]
    render json: { filename: url_for(attachment.image) }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :content)
    end
end
