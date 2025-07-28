require 'rails_helper'


RSpec.describe "Api::V1::Articles", type: :request do
  def auth_headers_for(user)
    post "/api/v1/auth/sign_in", params: {
      email: user.email,
      password: user.password
    }

    {
      'access-token' => response.headers['access-token'],
      'client' => response.headers['client'],
      'uid' => response.headers['uid'],
      'Content-Type' => 'application/json'
    }
  end

  let(:user) { create(:user, password: 'password') }
let(:headers) { auth_headers_for(user) }

it "記事を作成できる" do
  post "/api/v1/articles", params: {
    article: {
      title: "タイトル",
      body: "本文"
    }
  }.to_json, # ← JSON形式で渡す
  headers: headers.merge({ 'Content-Type' => 'application/json' })

  expect(response).to have_http_status(:created)
end
  describe "GET /api/v1/articles" do
    before do
      create_list(:article, 3, updated_at: Time.current + 1.day)  # 更新日時も指定
    end

    it "記事一覧を取得できる" do
      get "/api/v1/articles"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.length).to eq(3)
      expect(json[0]).to include("id", "title", "updated_at") # 本文が含まれていない
      expect(json[0]).not_to include("body") # 本文がないことを確認
    end
  end

  describe "GET /api/v1/articles/:id" do
    let(:article) { create(:article) }

    it "記事の詳細情報を取得できる" do
      get "/api/v1/articles/#{article.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["id"]).to eq(article.id)
      expect(json["title"]).to eq(article.title)
      expect(json["body"]).to eq(article.body)
      expect(json["updated_at"]).to be_present
      expect(json["user"]).to include(
        "id" => article.user.id,
        "name" => article.user.name
      )
    end
  end

  describe "POST /api/v1/articles" do
    let!(:user) { create(:user) }

    before do
      # current_user をテスト時だけスタブ
      allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(user)
    end

    it "記事を作成できる" do
      post "/api/v1/articles", params: {
        article: {
          title: "テストタイトル",
          body: "テスト本文"
        }
      }.to_json, # ← JSON形式で渡す
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("テストタイトル")
      expect(json["body"]).to eq("テスト本文")
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user, title: "Before", body: "Before body") }

    before do
      allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(user)
    end

    it "自分の記事を更新できる" do
      patch "/api/v1/articles/#{article.id}", params: {
        article: { title: "After", body: "After body" }
      }.to_json, # ← JSON形式
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("After")
      expect(json["body"]).to eq("After body")
    end

    it "他人の記事は更新できない" do
      other_user = create(:user)
      other_article = create(:article, user: other_user)

      patch "/api/v1/articles/#{other_article.id}", params: {
        article: { title: "不正更新" }
      }.to_json, # ← JSON形式
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("You are not authorized to update this article")
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    let(:user) { create(:user) }
    let(:headers) { user.create_new_auth_token }
    let!(:article) { create(:article, user: user) }

    context "認証済みのユーザーが自身の記事を削除する場合" do
      it "記事を削除できる" do
        expect {
          delete "/api/v1/articles/#{article.id}", headers: headers
        }.to change { Article.count }.by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "他人の記事を削除しようとした場合" do
      let(:other_user) { create(:user) }
      let(:other_article) { create(:article, user: other_user) }

      it "削除できず403エラーを返す" do
        delete "/api/v1/articles/#{other_article.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["error"]).to eq("権限がありません")
      end
    end

    context "未認証の場合" do
      it "401エラーが返る" do
        delete "/api/v1/articles/#{article.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end