class Post < ApplicationRecord
  validates :title, :content, :genre, :image, presence: true
  enum genre: [:public_post, :friend_only, :private_post]
  belongs_to :user

  mount_uploader :image, ImageUploader
end
