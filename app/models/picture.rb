class Picture < ActiveRecord::Base
  validates_uniqueness_of :user_id
end