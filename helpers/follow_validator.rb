class FollowValidator < ActiveModel::Validator

  def validate(record)
    # prevents user following itself
    if(record.follower == record.followed)
      record.errors[:follower] << 'User cannot follow itself'
    end
    # Prevents duplicate follows
    if(record.new_record? && Follow.where(follower: record.follower, followed: record.followed).exists?)
      record.errors[:follower] << 'Follow already exists'
    end
    
  end
end
