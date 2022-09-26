class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:edit, :update, :destroy]
  after_action :verify_authorized, only: [:edit, :update, :destroy]

  def index
    friend_ids = current_user.friendships.accepted.pluck(:friend_id) + current_user.inverse_friendships.accepted.pluck(:user_id)
    friends_post = Post.where(user_id: friend_ids).where.not(genre: :private_post)
    user_post = current_user.posts
    public_posts = Post.public_post
    @post_in_index = Post.where(id: friends_post + user_post + public_posts).includes(:user)
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save
      flash[:notice] = "Successfully Created"
      redirect_to posts_path
    else
      flash[:alert] = @post.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    authorize @post,:edit?, policy_class: PostPolicy
  end

  def update
    authorize @post,:update?, policy_class: PostPolicy
    if @post.update(post_params)
      flash[:notice] = "Successfully Updated"
      redirect_to posts_path
    else
      flash[:alert] = @post.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    authorize @post,:destroy?, policy_class: PostPolicy
    if @post.destroy
      flash[:notice] = "Successfully Deleted"
      redirect_to posts_path
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :image, :genre)
  end
end