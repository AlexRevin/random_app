class Picture < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :user_id

  after_create do
    if first_pic.present?
      PictureItem.create(url: first_pic, order: 0, user_id: user_id)
    end
    [*urls&.split(",")].each_with_index do |url, index|
      PictureItem.create(url: url, order: index + 1, user_id: user_id)
    end
  end

  def sync_picture_items!
    items = user.picture_items.select(:id, :url,).all
    all_photos = [first_pic, urls&.split(",")].flatten.compact
    all_photos.each_with_index do |url, index|
      existing = items.detect{|item| item.url == url}
      existing.present? ?
        existing.update(order: index) :
        existing.picture_items.create(url: url, order: index)
    end
    items.reject{|item| all_photos.include?(item.url)}.map(&:destroy) if items.length > 0
  end
end