require 'byebug'

class Tweet <ActiveRecord::Base
   belongs_to :author, :class_name => "User"

  validates :text, presence: true, length: { maximum: 140 }
  validates :author, presence: true

  after_initialize :set_default_values

  def set_default_values
    self.likes ||= 0
  end

  def increment_likes
    self.likes += 1
  end

  def decrement_likes
    if self.likes >0
      self.likes -= 1
    end
  end

  def is_reply?
    self.reply
  end

end
