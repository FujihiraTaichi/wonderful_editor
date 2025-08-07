require 'rails_helper'

RSpec.describe 'User Session API', type: :request do
  let(:user) { create(:user, password: 'password') }

  describe 'POST /api/v1/auth/sign_in' do
    context '正常系' do
      it '正しいメールアドレスとパスワードでログインでき、トークンが返る' do
        post '/api/v1/auth/sign_in', params: { email: user.email, password: 'password' }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']['email']).to eq(user.email)
        expect(response.headers['access-token']).to be_present
        expect(response.headers['client']).to be_present
        expect(response.headers['uid']).to eq(user.email)
      end
    end

    context '異常系' do
      it 'パスワードが間違っているとログインできない' do
        post '/api/v1/auth/sign_in', params: { email: user.email, password: 'wrongpassword' }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end

      it '存在しないメールアドレスではログインできない' do
        post '/api/v1/auth/sign_in', params: { email: 'notfound@example.com', password: 'password' }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/auth/sign_out' do
    context '正常系' do
      it '有効なトークンでログアウトできる' do
        # まずログインしてトークンを取得
        post '/api/v1/auth/sign_in', params: { email: user.email, password: 'password' }
        token_headers = response.headers.slice('access-token', 'client', 'uid')
        delete '/api/v1/auth/sign_out', headers: token_headers
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be_truthy
      end
    end

    context '異常系' do
      it 'トークンなしではログアウトできない' do
        delete '/api/v1/auth/sign_out'
        expect(response).to have_http_status(:not_found).or have_http_status(:unauthorized)
      end

      it '不正なトークンではログアウトできない' do
        headers = { 'access-token' => 'invalid', 'client' => 'invalid', 'uid' => user.email }
        delete '/api/v1/auth/sign_out', headers: headers
        expect(response).to have_http_status(:not_found).or have_http_status(:unauthorized)
      end
    end
  end
end
