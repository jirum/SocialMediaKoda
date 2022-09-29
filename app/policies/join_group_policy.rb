class JoinGroupPolicy < ApplicationPolicy
  def accept?
    admin? || moderator?
  end
  def remove?
    admin? || moderator?
  end
  def leave?
    record.user == user
  end
  def resend?
    record.user == user
  end
  def ignore?
    admin? || moderator?
  end
  def edit?
    record.user == user
  end
  def update?
    admin? || moderator?
  end
  def admin?
    user.join_groups.find_by(group: record.group)&.admin?
  end
  def moderator?
    user.join_groups.find_by(group: record.group)&.moderator?
  end
end