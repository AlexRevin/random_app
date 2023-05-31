class User < ActiveRecord::Base
  has_one :picture
  has_many :picture_items

end