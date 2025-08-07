require 'rails_helper'

RSpec.describe 'User Registration API', type: :request do
  describe 'POST /api/v1/auth' do
    let(:valid_params) do
      {
        name: '新規ユーザー',
        email: 'newuser@example.com',
        password: 'password',
        password_confirmation: 'password'
      }
    end

    context '正常系' do
      it 'ユーザーがDBに保存され、レスポンスボディ・ヘッダーに必要な情報が含まれる' do
        expect {
          post '/api/v1/auth', params: valid_params
        }.to change { User.count }.by(1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['status']).to eq('success')
        expect(json['data']['email']).to eq(valid_params[:email])
        expect(json['data']['name']).to eq(valid_params[:name])

        # トークン系ヘッダーの検証
        expect(response.headers['access-token']).to be_present
        expect(response.headers['client']).to be_present
        expect(response.headers['uid']).to eq(valid_params[:email])
      end
    end

    context '異常系' do
      it 'パラメータ不足（emailなし）でエラーになる' do
        post '/api/v1/auth', params: valid_params.except(:email)
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to be_present
      end

      it 'パスワード不一致でエラーになる' do
        params = valid_params.merge(password_confirmation: 'different')
        post '/api/v1/auth', params: params
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']['password_confirmation']).to be_present
      end

      it 'メールアドレス重複でエラーになる' do
        create(:user, email: valid_params[:email])
        post '/api/v1/auth', params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']['email']).to be_present
      end
    end
  end
end
