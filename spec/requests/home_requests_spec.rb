require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'list of users' do
    before(:example) do
      10.times.each do
        user = User.create
        user.create_picture!(
          first_pic: 'http://foo.io/1.jpg',
          urls: 'http://foo.io/2.jpg,http://foo.io/3.jpg'
        )
        user.picture_items = [
          PictureItem.new(url: 'http://foo.io/1.jpg'),
          PictureItem.new(url: 'http://foo.io/2.jpg'),
          PictureItem.new(url: 'http://foo.io/3.jpg')
        ]
        user.save!
      end
    end
    it 'return all users' do
      get '/users'

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(10)
      expect(JSON.parse(response.body)[0]).to eq({
        "id"=>1,
        "pic"=>["http://foo.io/1.jpg", "http://foo.io/2.jpg", "http://foo.io/3.jpg"]
      })
    end

    it 'return all users' do
      get '/users_v2'

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body).count).to eq(10)
      expect(JSON.parse(response.body)[0]).to eq({
        "id"=>1,
        "pic"=>["http://foo.io/1.jpg", "http://foo.io/2.jpg", "http://foo.io/3.jpg"]
      })
    end
  end

  describe 'update picture' do
    it 'creates if not exists' do
      current_user = User.create
      params = {
        first_pic: 'http://foo.io/1.jpg',
        urls: ['http://foo.io/2.jpg', 'http://foo.io/3.jpg']
      }
      post "/update_user/#{current_user.id}", params

      expect(Picture.count).to eq(1)
      expect(response.status).to eq(200)

      expect(PictureItem.count).to eq(3)
      expect(PictureItem.first.order).to eq(0)
      expect(PictureItem.first.url).to eq(params[:first_pic])

    end

    it 'sets first pic by default' do
      current_user = User.create
      params = {
        urls: ['http://foo.io/2.jpg', 'http://foo.io/3.jpg']
      }
      post "/update_user/#{current_user.id}", params

      expect(PictureItem.count).to eq(2)
      expect(PictureItem.first.order).to eq(0)
      expect(PictureItem.first.url).to eq(params[:urls][0])

    end

    it 'creates first pic only' do
      current_user = User.create
      params = {
        first_pic: 'http://foo.io/1.jpg',
      }
      post "/update_user/#{current_user.id}", params

      expect(PictureItem.count).to eq(1)
      expect(PictureItem.first.order).to eq(0)
      expect(PictureItem.first.url).to eq(params[:first_pic])

    end

    it 'returns current state' do
      current_user = User.create
      post "/update_user/#{current_user.id}"
      expect(response.status).to eq(200)
      expect(response.body).to eq({id: 1, pictures: []}.to_json)
    end

    it 'supports updating' do
      current_user = User.create
      current_user.create_picture!(
        first_pic: 'http://foo.io/1.jpg',
        urls: 'http://foo.io/2.jpg,http://foo.io/3.jpg'
      )

      params = {
        first_pic: 'http://foo.io/1.jpg',
        urls: ['http://foo.io/2.jpg']
      }
      post "/update_user/#{current_user.id}", params
      expect(response.status).to eq(200)
      expect(response.body).to eq( {id: 1, pictures: ['http://foo.io/1.jpg', 'http://foo.io/2.jpg']}.to_json)
      expect(PictureItem.first.url).to eq(params[:first_pic])
      expect(PictureItem.last.url).to eq(params[:urls][0])
    end

    it 'supports reordering' do
      current_user = User.create
      current_user.create_picture!(
        first_pic: 'http://foo.io/1.jpg',
        urls: 'http://foo.io/2.jpg,http://foo.io/3.jpg'
      )

      params = {
        first_pic: 'http://foo.io/3.jpg',
        urls: ['http://foo.io/2.jpg', 'http://foo.io/1.jpg']
      }
      post "/update_user/#{current_user.id}", params
      urls = ['http://foo.io/3.jpg', 'http://foo.io/2.jpg', 'http://foo.io/1.jpg']
    
      expect(response.status).to eq(200)
      expect(response.body).to eq({id: 1, pictures: urls}.to_json)
      expect(PictureItem.ordered.pluck(:url)).to eq(urls)
    end
  end
end