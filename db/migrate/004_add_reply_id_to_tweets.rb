class AddReplyIdToTweets < ActiveRecord::Migration
  def change
    add_column :tweets, :reply_id , :integer
  end
end