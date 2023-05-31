class PictureItem < ActiveRecord::Base
  scope :ordered, ->{ order(order: :asc)}
end
