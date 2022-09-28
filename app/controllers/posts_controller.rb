class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:edit, :update, :destroy]
  after_action :verify_authorized, only: [:edit, :update, :destroy]
  include ApplicationHelper

  def index
    @post_in_index = Post.where(id: all_posts(current_user)).includes(:user)
  end

  def new
    @post = Post.new
  end

  def create
    begin
      @post = Post.new(post_params)
      @post.user = current_user
      if params[:display_location] == '1'
        service = IpGeolocationService.new
        location = service.get_location(RestClient.get('https://icanhazip.com/'))
        @post.country = location['country_name']
        @post.city = location['city']
      end
    rescue
      flash[:alert] = "You created a post but don't have location"
    end
    if @post.save
      flash[:notice] = "Successfully Created"
      redirect_to posts_path
    else
      flash[:alert] = @post.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    authorize @post, :edit?, policy_class: PostPolicy
  end

  def update
    @post.assign_attributes(post_params)
    begin
      if params[:display_location] == '1'
        service = IpGeolocationService.new
        location = service.get_location(RestClient.get('https://icanhazip.com/'))
        @post.country = location['country_name']
        @post.city = location['city']
      else
        @post.country = nil
        @post.city = nil
      end
    rescue
      flash[:alert] = "You updated a post but don't have location"
    end
    authorize @post, :update?, policy_class: PostPolicy
    if @post.save
      flash[:notice] = "Successfully Updated"
      redirect_to posts_path
    else
      flash[:alert] = @post.errors.full_messages.join(', ')
      render :edit
    end
  end

  def destroy
    authorize @post, :destroy?, policy_class: PostPolicy
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