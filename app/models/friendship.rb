class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  include AASM
  aasm column: :state do
    state :pending, initial: true
    state :accepted, :cancelled

    event :accept do
      transitions from: :pending, to: :accepted
    end

    event :cancel do
      transitions from: :pending, to: :cancelled
    end

    event :resend do
      transitions from: :cancelled, to: :pending
    end
  end
end
