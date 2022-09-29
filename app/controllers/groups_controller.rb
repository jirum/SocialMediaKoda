class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, except: [:index, :new, :create]

  def index
    group_ids = current_user.join_groups.where.not(state: [:ignored, :removed, :left]).pluck(:group_id)
    @groups = Group.where.not(id: group_ids).order(id: :desc) if params[:group] == 'group_list' || params[:group].blank?
    @own_group = Group.where(user_id: current_user) if params[:group] == 'own_group'
    @joined_groups = current_user.join_groups.accepted.where.not(is_owner: true).includes(:group) if params[:group] == 'joined_group'
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    @group.user = current_user
    @join_group = JoinGroup.new(user: current_user, state: :accepted, role: :admin, is_owner: true, group: @group)
    if @group.save && @join_group.save
      flash[:notice] = "Successfully Created"
      redirect_to groups_path(group: 'own_group')
    else
      flash[:alert] = @group.errors.full_messages.join(', ') || flash[:alert] = @join_group.errors.full_messages.join(', ')
      render :new
    end
  end

  def edit
    authorize @group, :edit?, policy_class: GroupPolicy
  end

  def update
    authorize @group, :update?, policy_class: GroupPolicy
    if @group.update(group_params)
      flash[:notice] = "Successfully Updated"
      redirect_to groups_path
    else
      flash[:alert] = @group.errors.full_messages.join(', ')
      render :edit
    end
  end

  def show
    @requests = JoinGroup.where.not(user: current_user).pending if params[:group] == 'request'
    @members = JoinGroup.where(group: @group).accepted.includes(:user) if params[:group] == 'members'
  end

  def destroy
    authorize @group, :destroy?, policy_class: GroupPolicy
    if @group.destroy
      flash[:notice] = "Successfully Deleted"
      redirect_to groups_path
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name, :description, :genre, :banner)
  end
end