class JoinGroupsController < ApplicationController
  before_action :set_join_group, except: [:new, :create]

  def new
    @join_group = JoinGroup.new
  end

  def create
    if removed_left_user = current_user.join_groups.where(state: [:removed, :left, :ignored]).find_by(group_id: params[:group_id])
      removed_left_user.resend!
      flash[:notice] = "Successfully Resend"
    elsif current_user.join_groups.find_by(group_id: params[:group_id]).nil?
      join_group = current_user.join_groups.new(group_id: params[:group_id], role: :normal)
      join_group.save!
      flash[:notice] = "Request Sent"
    else
      flash[:alert] = "You already sent a request"
    end
    redirect_to groups_path
  end

  def update
    authorize @join_group, :update?, policy_class: JoinGroupPolicy
    if @join_group.update(role: params[:join_group][:role])
      flash[:notice] = "Successfully Updated"
    else
      flash[:alert] = @join_group.errors.full_messages.join(', ')
    end
    redirect_to group_path(params[:group_id], group: 'members')
  end

  def accept
    authorize @join_group, :accept?, policy_class: JoinGroupPolicy
    if @join_group.accept!
      flash[:notice] = "Successfully Accepted"
    else
      flash[:alert] = @join_group.errors.full_messages.join(', ')
    end
    redirect_to group_path(params[:group_id], group: 'request')
  end

  def remove
    authorize @join_group, :remove?, policy_class: JoinGroupPolicy
    if @join_group.remove!
      flash[:notice] = "Successfully Remove"
    else
      flash[:alert] = @join_group.errors.full_messages.join(', ')
    end
    redirect_to group_path(params[:group_id], group: 'members')
  end

  def leave
    authorize @join_group, :leave?, policy_class: JoinGroupPolicy
    if @join_group.leave!
      flash[:notice] = "Successfully Left"
    else
      flash[:alert] = @join_group.errors.full_messages.join(', ')
    end
    redirect_to groups_path(group: 'joined_group')
  end

  def ignore
    authorize @join_group, :ignore?, policy_class: JoinGroupPolicy
    if @join_group.ignore!
      flash[:notice] = "Successfully Ignored"
    else
      flash[:alert] = @join_group.errors.full_messages.join(', ')
    end
    redirect_to group_path(params[:group_id], group: 'request')
  end

  def resend
    authorize @join_group, :resend?, policy_class: JoinGroupPolicy
    if @join_group.resend!
      flash[:notice] = "Successfully Resend Friend Request"
    else
      flash[:alert] = @join_group.errors.full_messages.join(', ')
    end
    redirect_to groups_path
  end

  private

  def set_join_group
    @join_group = JoinGroup.find(params[:join_group_id] || params[:id])
  end

end