class HomeController < ApplicationController
  def index
    users = User.includes(:picture).all

    resp = users.map do |user|
      {
        id: user.id,
        pic: user.picture ? [user.picture.first_pic, user.picture.urls&.split(",")].flatten : []
      }
    end
    render json: resp
  end

  def index_v2
    users = User.includes(:picture_items).all

    resp = users.map do |user|
      {
        id: user.id,
        pic: user.picture_items.ordered.map(&:url)
      }
    end
    render json: resp
  end

  def update_user
    user = User.find(params[:id])

    if user.picture.nil? && (params[:first_pic] || params[:urls])
      picture = user.create_picture!(
        first_pic: params[:first_pic],
        urls: params[:urls]&.join(",")
      )
      picture.sync_picture_items!

    elsif user.picture
      user.picture.update!(first_pic: params[:first_pic]) if params[:first_pic]
      user.picture.update!(urls: params[:urls].join(",")) if params[:urls]
      user.picture.sync_picture_items!
    end

    render json: {
      id: user.id,
      pictures: user.picture ? [user.picture.first_pic, user.picture.urls&.split(",")].flatten : [],
    }
  end
end