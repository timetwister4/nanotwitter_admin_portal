require 'redis'
require 'sinatra'
require 'sinatra/activerecord'
require_relative 'models/user.rb'
require_relative 'models/tweet.rb'
require_relative 'models/follow.rb'
require 'json'
require 'byebug'

class RedisClass

	def self.cache_tweet(tweet,user_id, tweet_id)
		#$redis.sadd("tweet:#{tweet_id}", tweet.to_json)
		if $redis.lrange("ffeed", 0, -1).length == 50
		   $redis.rpop("ffeed")
		   $redis.lpush("ffeed", tweet.to_json)
		else
		   $redis.lpush("ffeed", tweet.to_json)
		end
		$redis.lpush("user:#{user_id}:pfeed", tweet.to_json) #cache tweet for self
		followers = Follow.where(followed_id: user_id)
		followers.each do |follow|
			$redis.lpush("user:#{follow.follower_id}:hfeed", tweet.to_json)
		end

	end
	
	def self.number_of_keys
		$redis.dbsize
	end

	def self.delete_keys
		$redis.flushdb
	end

	def self.delete_user_keys(id)
		$redis.del("user:#{id}:hfeed")
		$redis.del("user:#{id}:pfeed")
		$redis.del("user:#{id}:followings")
		$redis.del("user:#{id}:followers")
	end

	

	# def self.access_pfeed(u_id)
	# 	$redis.lrange("user:#{u_id}:pfeed", 0, -1) #return the unparsed tweets of your nt profile
	# 	# tweets = []
	# 	# ids.each do |id|
	# 	#  	$redis.smembers("tweet:#{id}")
	# 	#  	tweets.push(tweet)
	#  #    end
			
	# end

	# def self.access_hfeed(u_id)
	# 	$redis.lrange("user:#{u_id}:hfeed", 0, -1) #return the unparsed tweets of your nt profile
	# 	# tweets = []
	# 	# ids.each do |id|
	# 	# 	 tweets.push($redis.smembers("tweet:#{id}"))
	# 	# end
	# 	# return tweets
	# end




	#************non-load testing pursposes **************#



	






	# def self.cache_reply(reply, tweet_id)
	# 	$redis.rpush("tweet:#{tweet_id}:replies", reply.to_json)
	# end

	# def self.cache_mentions(users_ids, tweet)
	# 	users_ids.each do |id|
	# 		$redis.rpush("user:#{id}:mentions", tweet.to_json)
	# 	end

	# end

	# def self.cache_tags(tag_names, tweet)
	# 	tag_names do |name|
	# 		$redis.rpush("tag:#{name}", tweet.to_json)
	# 	end

	# end

	# def self.cache_likes(t_id, u_id, t) #we need to store likes so that a user cannot like the tweet two times
	#     if $redis.sismember("tweet:#{t_id}:likes", u_id) == false
	# 			$redis.sadd("tweet:#{t_id}:likes", u_id)
	# 			t.increase_likes
	# 			return true
	# 		end
	# end


	

	# def self.load_ffeed (tweets)
	# 	self.delete_ffeed
	# 	tweets.each do |tweet|
	# 		$redis.rpush("ffeed", tweet.id)
	# 	end
	# end
	# #experiment
	# def self.access_ffeed
	# 	ids = $redis.lrange("ffeed", 0, 7)
	# 	tweets = []
	# 	ids.each do |id|
	# 		tweet = $redis.smembers("tweet:#{id}")
	# 		tweets.push(tweet)
	# 	end
	# 	return tweets

	#access the ids of all the people that the person with the given id (u_id) follows
	# def self.access_followings(u_id)
	# 	$redis.smembers("user:#{u_id}:followings")
	# end
	# #access the ids of all the people that follow the person with the given id (u_id)
	# def self.access_followers(u_id)
	# 	$redis.smembers("user:#{u_id}:followers")
	# end

	


	# def self.access_tag(name)
	# 	$redis.lrange("tag:#{name}", 0, -1)
	# end


	# def self.access_replies(tweet_id)
	# 	$redis.lrange("tweet:#{tweet_id}:replies", 0, -1)
	# end

	# def self.access_likes(tweet_id)
	# 	$redis.smembers("tweet:#{tweet_id}:likes")
	# end



	# def self.delete_ffeed
	# 	$redis.del("ffeed")
	# end

	# def self.delete_user_from_follows(id)
	# 	users = User.all
	# 	users.each do |u|
	# 		followers = $redis.smembers("user:#{u[0].id}:followers")
	# 		followings = $redis.smembers("user:#{u[0].id}:followings")
	# 		followers.delete(id)
	# 		followings.delete(id)
	# 	end

	# end




end
