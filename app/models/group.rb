class Group < ApplicationRecord
  validates :name, :description, :genre, :banner, presence: true
  enum genre:[:hidden, :public_group]

  belongs_to :user
  has_many :join_groups

  mount_uploader :banner, ImageUploader
end