require 'csv'
require 'faker'
require_relative 'redis_operations.rb'

Dir["models/*.rb"].each {|file| require_relative file }

def create_test_user
   User.create(name: "testuser", email: "testuser@sample.com", user_name: "testuser", password: "password")
end

def get_status
  time = Time.now
  users = User.all.count
  tweets = Tweet.all.count
  follows = Follow.all.count
  redis =  RedisClass.number_of_keys
  {:time => time, :users => users, :tweets => tweets, :follows => follows, :redis => redis}
end

def reset_all_database
  User.delete_all
  Tweet.delete_all
  Follow.delete_all
end

def reset_all_redis
  RedisClass.delete_keys
end

def perform_test
  init_status = get_status
  yield
  fin_status = get_status
  {:init_status => init_status, :fin_status => fin_status}
end

def seed_users
  CSV.foreach('./seed_data/users.csv') do |row|
    User.create(name: row[1], email: "#{row[1]}@cosi105b.gov", user_name: row[1], password: "123")
  end
end


def seed_follows
  user = User.first
  user_id = user.id
  row_num = 1
  CSV.foreach('./seed_data/follows.csv') do |row|
    if row_num != row[0].to_i
      increase = row[0].to_i - row_num
      user_id += increase
      row_num = row[0].to_i
      User.find(user_id)
    else
      diff = (row[1].to_i - row[0].to_i).abs
      row[1].to_i > row[0].to_i ? f_id = user_id + diff : f_id = user_id - diff
      Follow.create(follower_id: user_id, followed_id: f_id)
      RedisClass.cache_follow(user_id, f_id)
    end

  end
  # user = User.first
  # start_index = user.id - 1
  # CSV.foreach('./seed_data/follows.csv') do |row|
  #   if row[0].to_i + start_index != user.id
  #     user = User.find(row[0].to_i + start_index)
  #   end

  #   #user.increment_followings
  #   user.save

  #   followed_user = User.find(row[1].to_i + start_index)
  #   followed_user.increment_followers
  #   followed_user.save

  #   Follow.create(follower_id: row[0].to_i + start_index, followed_id: row[1].to_i + start_index)
  #   RedisClass.cache_follow(user.id, followed_user.id)

end

def seed_tweets
  user = User.first
  user_id = user.id
  tweets_per_user = 0
  row_num = 1
  CSV.foreach('./seed_data/tweets.csv') do |row|
    if row_num != row[0].to_i
       increase = row[0].to_i - row_num
       tweets_per_user = 0
       user_id += increase   
       row_num = row[0].to_i
       user = User.find(user_id)
    elsif tweets_per_user < 12 
      t = Tweet.create(author_id: user_id, author_name: user[:name], text: row[1], created_at: row[2])
      t.save
      tweet = [user[:name], row[1], row[2], t.id]
      RedisClass.cache_tweet(tweet,user_id,t.id)
      tweets_per_user += 1
    end
  end

  #   if tweet_count >= 8000
  #     break
  #   else
  #     if row[0].to_i + start_index  != user.id
  #       user = User.find(row[0].to_i + start_index)
  #     end
  #     t = Tweet.create(author_id: user.id, author_name: user[:name], text: row[1], created_at: row[2])
  #     user.increment_tweets
  #     user.save
  #     tweet_count += 1
  #   end
  # end
end




def reset_all
  reset_all_database
  reset_all_redis
  create_test_user
end

def fabricate_user_activity(count, tweets)
  count.to_i.times do
    uname = Faker::Name.name
    user = User.create(name: uname, email: Faker::Internet.safe_email(uname), user_name: Faker::Internet.user_name(uname, %w(. _ -)), password: Faker::Internet.password)
    fabricate_tweets(user,tweets)
  end
end

def fabricate_tweets (user, count)
  if user[0]
    count.to_i.times do
      Tweet.create(author_id: user.id, author_name: user[:user_name], text: Faker::Hacker.say_something_smart)
      user.increment_tweets
    end
  end
end

def reset_test_user
  delete_user_data(User.where(user_name: "testuser")[0])
end

def delete_user_data(user)
  Tweet.where(author: user).destroy_all
  Follow.where(follower: user).destroy_all
  Follow.where(followed: user).destroy_all
  RedisClass.delete_user_keys(user.id)
  RedisClass.delete_user_from_follows(user.id)
end

def follow_test (user_name, count)
  user = User.where(user_name: user_name)[0]
  follows = Follow.where(followed: user)
  #Ensures user does not try to follow themself - should deny the creation, but would ultimately mean :count-1 follows
  to_follow = User.where_not("id = ? or id = ?", follows.id, user.id).order("RANDOM()").first(count)
  to_follow.each do |obj|
    Follow.create(follower: obj, following: user)
    obj.increment_followings
    user.increment_followers
  end
end

def compare_status(s_current, s_init)
  time = s_current.to_a[0][1] - s_init.to_a[0][1]
  users = s_current.to_a[1][1] - s_init.to_a[1][1]
  tweets = s_current.to_a[2][1] - s_init.to_a[2][1]
  follows = s_current.to_a[3][1] - s_init.to_a[3][1]
  {:time => time, :users => users, :tweets => tweets, :follows => follows}
end
