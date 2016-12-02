require 'redis'
#$redis = Redis.new(:host => 'localhost', :port => 6379)
$redis = Redis.new(url: ENV["REDIS_URL"])
