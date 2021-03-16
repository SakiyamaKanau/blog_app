class PostsController < ApplicationController
 
 def new
    @post = Post.new
 end
 
  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to post_path(@post), notice: "ブログを投稿しました。"
    else
      render :new
    end
  end
  
  def index
    @posts = Post.all.order(id: "DESC")
    ids = REDIS.zrevrangebyscore "posts/daily/#{Date.today.to_s}", "+inf", 0,limit:[0,3]
    @ranking_posts = ids.map{ |id| Post.find(id) }
  end
  
  def show
    @post = Post.find(params[:id])
    REDIS.zincrby "posts/daily/#{Date.today.to_s}", 1, "#{@post.id}"
  end
  
  def edit
    @post = Post.find(params[:id])
    if @post.user != current_user
        redirect_to posts_path, alert: "不正なアクセスです。"
    end
  end
  
  def update
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to post_path(@post), notice: "ブログを更新しました。"
    else
      render :edit
    end
  end
  
  def destroy
    @post = Post.find(params[:id])
     REDIS.zrem "posts/daily/#{Date.today.to_s}", @post.id
    @post.destroy
    redirect_to user_path(@post.user), notice: "ブログを削除しました。"
  end

  private
  def post_params
    params.require(:post).permit(:title, :body, :image, :comment)
  end
  
end
