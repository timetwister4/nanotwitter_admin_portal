require 'redis'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/user.rb'
require_relative 'models/tweet.rb'
require_relative 'models/follow.rb'
require 'json'
require 'byebug'


class RedisClass

  #pfeeds get refreshed when you access and when tweets
  def self.access_pfeed (user_id)
    pfeed = $redis.lrange("user:#{user_id}:pfeed", 0, -1)
    if pfeed == []
      pfeed = self.update_pfeed(user_id)
    end
    return pfeed
  end

  #call this when you tweet to update a pfeed
  def self.update_pfeed(user_id)
    pfeed = User.find(user_id).tweets.order(created_at: :desc).first(50)
    pfeed.each do |tweet|
      $redis.rpush("user:#{user_id}:pfeed", tweet.to_json)
    end
    pfeed = $redis.lrange("user:#{user_id}:pfeed", 0, -1)
    $redis.expire("user:#{user_id}:pfeed", 5)#stays fresh in the cache for a full second
    return pfeed
  end

  def self.access_ffeed
    ffeed = $redis.lrange("ffeed",0,-1)
    if ffeed == []
      ffeed = Tweet.order(created_at: :desc).first(50)
      ffeed.each do |tweet|
        $redis.rpush("ffeed", tweet.to_json)
      end
      $redis.expire("ffeed", 10)
    end
    return $redis.lrange("ffeed", 0, -1)
  end

  def self.cache_follow(user_id, person_followed)
		$redis.sadd("user:#{user_id}:followings", person_followed)
		$redis.sadd("user:#{person_followed}:followers", user_id)
    $redis.expire("user:#{user_id}:followings",86400)
    $redis.expire("user:#{person_followed}:followers",86400)
  end

	def self.cache_unfollow(user_id, person_unfollowed)
		$redis.srem("user:#{user_id}:followings", person_unfollowed)
		$redis.srem("user:#{person_unfollowed}:followers", user_id)
	end

  def self.load_followings(user_id)
    follows = User.find(user_id).followed_users
    follows.each do |follow|
      $redis.sadd("user:#{user_id}:followings", follow[:followed_id])
    end
    return $redis.smembers("user:#{user_id}:followings")
  end

  def self.load_followers(user_id)
    follows = User.find(user_id).followers
    follows.each do |follow|
      $redis.sadd("user:#{user_id}:followers", follow[:follower_id])
    end
    return $redis.smembers("user:#{user_id}:followers")
  end

  def self.access_followings(user_id)
    followings = $redis.smembers("user:#{user_id}:followings")
    if followings == []
      followings = self.load_followings(user_id)
        $redis.expire("user:#{user_id}:followings",86400)
    end
    return followings
  end

  def self.access_followers(user_id)
    followers = $redis.smembers("user:#{user_id}:followers")
    if followers == []
      followers = self.load_followers(user_id)
      $redis.expire("user:#{user_id}:followers",86400)
    end
    return followers
  end

  def self.access_hfeed(user_id)
    hfeed = $redis.lrange("user:#{user_id}:hfeed", 0, -1)
    if hfeed == []
      hfeed = self.load_hfeed(user_id)
      $redis.expire("user:#{user_id}:hfeed", 2)
    end
    return hfeed
  end

  def self.load_hfeed(user_id)
    follows = self.access_followings(user_id)
    tweets = Tweet.where(author_id = follows).order(created_at: :desc).first(50)
    tweets.each do |tweet|
      $redis.rpush("user:#{user_id}:hfeed", tweet.to_json)
    end
    return $redis.lrange("user:#{user_id}:hfeed", 0, -1)
  end

  def self.number_of_keys
    $redis.dbsize
  end

  def self.delete_keys
    $redis.flushdb
  end

  def self.delete_user_keys(user_id)
    $redis.del("user:#{user_id}:hfeed")
    $redis.del("user:#{user_id}:pfeed")
    $redis.del("user:#{user_id}:followings")
    $redis.del("user:#{user_id}:followings")
  end

  def self.delete_user_from_follows(user_id)
    subscriptions = Follow.where(follower_id: user_id)
    subscriptions.each do |follow|
      $redis.smembers("user:#{follow.followed_id}:followers").delete(user_id)
    end

    subscribers = Follow.where(followed_id: user_id)
    subscribers.each do |follow|
      $redis.smembers("user:#{follow.follower_id}:followings").delete(user_id)
    end
  end

end
