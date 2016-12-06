require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'

require_relative 'testfunctions.rb'
require_relative 'config/environments'
require_relative 'config/initializers/redis'
#require_relative 'redis_operations.rb'
require_relative 'RedisClass.rb'

use Rack::Auth::Basic, "Protected Area" do |username, password|
  username == 'admin' && password == ENV['ADMIN_PASS']
end

get '/' do
  erb :index
end

get '/test/status' do
  get_status.to_json
end

get '/test/reset/all' do
  @message = perform_test {reset_all}
  erb :test_page
end

get '/test/reset/testuser' do
  @message = perform_test {reset_test_user}
  erb :test_page
end

get '/test/reset/standard' do
  Thread.new{
      reset_all_database
      reset_all_redis
      seed_users
      seed_follows
      seed_tweets
    }
  redirect '/test/status'
end

get '/test/users/create?count=:count&tweets=:tweets' do
  result = perform_test {
    fabricate_user_activity(params[:count], params[:tweets])
  }
  @message = compare_status(result[:final_status], result[:init_status]).to_json
  erb :test_page
end

get '/test/user/:user_name/tweets?count=:count' do
  result = perform_test{fabricate_tweets(User.where(user_name: params[:user_name]), params[:count])}
  @message = compare_status(result[:final_status], result[:init_status]).to_json
  erb :test_page
end

get '/test/user/:user_name/follow?count=:count' do
  result = perform_test{follow_test(params[:user_name], params[:count])}
  @message = compare_status(result[:final_status], result[:init_status]).to_json
  erb :test_page
end
