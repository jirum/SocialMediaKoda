class JoinGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group
  enum role: [:admin, :moderator, :normal]

  include AASM
  aasm column: :state do
    state :pending, initial: true
    state :accepted, :ignored, :removed, :left

    event :accept do
      transitions from: [:pending, :ignored, :removed, :left], to: :accepted
    end

    event :ignore do
      transitions from: :pending, to: :ignored
    end

    event :remove do
      transitions from: :accepted, to: :removed
    end

    event :leave do
      transitions from: :accepted, to: :left
    end

    event :resend do
      transitions from: [:ignored, :removed, :left], to: :pending
    end
  end
end
