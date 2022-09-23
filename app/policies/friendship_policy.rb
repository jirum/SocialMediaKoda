class FriendshipPolicy < ApplicationPolicy

  def accept?
    record.friend == user
  end

  def cancel?
    record.friend == user
  end

end