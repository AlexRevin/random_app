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
    # TODO
  end

  def update_user
    user = User.find(params[:id])

    if user.picture.nil? && (params[:first_pic] || params[:urls])
      user.create_picture!(
        first_pic: params[:first_pic],
        urls: params[:urls].join(",")
      )
    elsif user.picture
      user.picture.update!(first_pic: params[:first_pic]) if params[:first_pic]
      user.picture.update!(urls: params[:urls].join(",")) if params[:urls]
    end

    render json: {
      id: user.id,
      pictures: user.picture ? [user.picture.first_pic, user.picture.urls&.split(",")].flatten : []
    }
  end
end