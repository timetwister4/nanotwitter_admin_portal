configure :development do
  puts "[running in development mode]"
  ActiveRecord::Base.establish_connection(
    :adapter => :sqlite3,
    :database =>  "db/development.sqlite3.db"
  )
end


configure :production do
  puts "[running in production mode]"
  #puts "*********************************************#{ENV['DATABASE']}"
  ActiveRecord::Base.establish_connection(ENV['DATABASE'])
end
