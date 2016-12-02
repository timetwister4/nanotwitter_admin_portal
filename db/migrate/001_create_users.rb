class CreateUsers <ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :user_name
      t.string :email
      t.string :password_hash
      t.integer :follower_count
      t.integer :following_count
      t.integer :tweet_count
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
