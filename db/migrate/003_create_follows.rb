class CreateFollows <ActiveRecord::Migration
  def self.up
    create_table :follows do |t|
      t.belongs_to :follower, class_name: "User"
      t.belongs_to :followed, class_name: "User"
    end
  end

  def self.down
    drop_table :follows
  end
end
