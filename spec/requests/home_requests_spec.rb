require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'list of users' do
    it 'return all users' do
      10.times.each do
        user = User.create
        user.create_picture!(
          first_pic: 'http://foo.io/1.jpg',
          urls: 'http://foo.io/2.jpg,http://foo.io/3.jpg'
        )
      end

      get '/users'

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
    end

    it 'returns current state' do
      current_user = User.create
      post "/update_user/#{current_user.id}"
      expect(response.status).to eq(200)
      expect(response.body).to eq("{\"id\":1,\"pictures\":[]}")
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
      expect(response.body).to eq("{\"id\":1,\"pictures\":[\"http://foo.io/1.jpg\",\"http://foo.io/2.jpg\"]}")
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
      expect(response.status).to eq(200)
      expect(response.body).to eq("{\"id\":1,\"pictures\":[\"http://foo.io/3.jpg\",\"http://foo.io/2.jpg\",\"http://foo.io/1.jpg\"]}")
    end
  end
end