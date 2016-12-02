require 'bcrypt'

class User <ActiveRecord::Base

  include BCrypt

  validates_uniqueness_of :user_name, :email #allows for uniqueness of handles and emails
  validates :user_name, presence: true, uniqueness: { case_sensitive: false}
  validates :email, presence: true, uniqueness: { case_sensitive: false}
  validates :password_hash, presence: true
  validates :name, presence: true

  has_many :tweets , :class_name => "Tweet",  :foreign_key => :author_id

  has_many :followers, :class_name => "Follow",
   :foreign_key => :followed_id

  has_many :followed_users, :class_name => "Follow",
    :foreign_key => :follower_id


  def to_json
    super(:except => :password)
  end

  # password encryption functions

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

 after_initialize :set_default_values

  def set_default_values
    self.follower_count ||= 0
    self.following_count ||= 0
    self.tweet_count ||=0
  end

  def increment_followers
    self.follower_count += 1
    self.save
  end

  def decrement_followers
    if(follower_count > 0)
      self.follower_count -= 1
      self.save
    end
  end

  def increment_tweets
    self.tweet_count += 1
    self.save
  end

  def decrement_tweets
    if(tweet_count > 0)
      self.tweet_count -= 1
      self.save
    end
  end

  def increment_followings
    self.following_count +=1
    self.save
  end

  def decrement_followings
    if (following_count > 0)
      self.following_count -= 1
      self.save
    end
  end

#consider adding following functions to the User class?
  #def tweet (text, etc)

  #def follow (user)

  #def unfollow (user)

  #def my_tweets

end
