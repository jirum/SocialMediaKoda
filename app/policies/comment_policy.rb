class CommentPolicy < ApplicationPolicy
  include ApplicationHelper

  def index?
    Post.where(id: all_posts(user)).include? record
  end

  def edit?
    record.user == user
  end

  def update?
    edit?
  end

  def destroy?
    record.user == user
  end
end