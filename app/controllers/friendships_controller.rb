class FriendshipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_friendship, only: [:accept, :cancel]

  def index
    friends_ids = current_user.friendships.where.not(state: :cancelled).pluck(:friend_id) + current_user.inverse_friendships.where.not(state: :cancelled).pluck(:user_id) + [current_user.id]
    @users = User.where.not(id: friends_ids) if params[:friendship].blank? || params[:friendship] == "user_list"
    @friends = current_user.friendships.or(current_user.inverse_friendships).accepted if params[:friendship] == 'friend_list'
    @friend_requests = current_user.inverse_friendships.pending if params[:friendship] == 'friend_request'

    @users = @users.where(email: params[:email]) if (params[:friendship] == 'user_list' || params[:friendship].blank?) && params[:email].present?
  end

  def create
    if cancelled_friend = current_user.friendships.cancelled.find_by(friend_id: params[:friend_id])
      cancelled_friend.resend!
    elsif current_user.inverse_friendships.where.not(state: :cancelled).find_by(user_id: params[:friend_id]).nil? && current_user.friendships.find_by(friend_id: params[:friend_id]).nil? && current_user.id != params[:friend_id].to_i
      friendship = current_user.friendships.new(friend_id: params[:friend_id])
      friendship.save
      flash[:notice] = "Request Sent"
    else
      flash[:alert] = "You Already Add Friend"
    end
    redirect_to friendships_path
  end

  def destroy
    friend_ids = current_user.friendships.accepted.pluck(:id) + current_user.inverse_friendships.accepted.pluck(:id)
    friendship = Friendship.where(id: friend_ids).find_by_id(params[:id])
    if friendship && friendship.destroy
      flash[:notice] = "Removed friendship."
    else
      flash[:alert] = "Failed to remove"
    end
    redirect_to friendships_path(friendship: :friend_list)
  end

  def accept
    authorize @friendship, :accept?, policy_class: FriendshipPolicy
    if @friendship.accept!
      flash[:notice] = "Successfully Accepted"
    else
      flash[:alert] = @friendship.errors.full_messages.join(', ')
    end
    redirect_to friendships_path(friendship: :friend_request)
  end

  def cancel
    authorize @friendship, :cancel?, policy_class: FriendshipPolicy
    if @friendship.cancel!
      flash[:notice] = "Successfully Ignored"
    else
      flash[:alert] = @friendship.errors.full_messages.join(', ')
    end
    redirect_to friendships_path(friendship: :friend_request)
  end

  def resend
    if @friendship.resend!
      flash[:notice] = "Successfully Resend Friend Request"
    else
      flash[:alert] = @friendship.errors.full_messages.join(', ')
    end
    redirect_to friendships_path
  end

  private

  def set_friendship
    @friendship = Friendship.find(params[:friendship_id])
  end
end