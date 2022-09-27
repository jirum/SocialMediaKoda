module ApplicationHelper

  def all_posts(user)
    friend_ids = user.friendships.accepted.pluck(:friend_id) + user.inverse_friendships.accepted.pluck(:user_id)
    friends_post = Post.where(user_id: friend_ids).where.not(genre: :private_post)
    user_post = user.posts
    public_posts = Post.public_post
    friends_post + user_post + public_posts
  end

end
