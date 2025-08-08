require 'rails_helper'

RSpec.describe "Api::V1::Articles", type: :request do
  let(:user) { create(:user, password: 'password') }
  let(:headers) { user.create_new_auth_token.merge('Content-Type' => 'application/json') }

  describe "GET /api/v1/articles" do
    before do
      create_list(:article, 3, status: :published, updated_at: Time.current + 1.day)
      create_list(:article, 2, status: :draft, updated_at: Time.current + 1.day)
    end

    it "公開記事一覧のみ取得できる" do
      get "/api/v1/articles"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json.length).to eq(3) # 公開記事のみ
      expect(json[0]).to include("id", "title", "updated_at")
      expect(json[0]).not_to include("body")
    end
  end

  describe "GET /api/v1/articles/:id" do
    let(:published_article) { create(:article, status: :published) }
    let(:draft_article) { create(:article, status: :draft) }

    it "公開記事の詳細情報を取得できる" do
      get "/api/v1/articles/#{published_article.id}"

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)

      expect(json["id"]).to eq(published_article.id)
      expect(json["title"]).to eq(published_article.title)
      expect(json["body"]).to eq(published_article.body)
      expect(json["updated_at"]).to be_present
      expect(json["user"]).to include(
        "id" => published_article.user.id,
        "name" => published_article.user.name
      )
    end

    it "下書き記事は取得できない" do
      get "/api/v1/articles/#{draft_article.id}"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("記事が見つかりません")
    end
  end

  describe "POST /api/v1/articles" do
    let!(:user) { create(:user) }

    it "下書き記事を作成できる" do
      post "/api/v1/articles", params: {
        article: {
          title: "下書きタイトル",
          body: "下書き本文",
          status: "draft"
        }
      }.to_json,
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("下書きタイトル")
      expect(json["body"]).to eq("下書き本文")
      expect(json["status"]).to eq("draft")
    end

    it "公開記事を作成できる" do
      post "/api/v1/articles", params: {
        article: {
          title: "公開タイトル",
          body: "公開本文",
          status: "published"
        }
      }.to_json,
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("公開タイトル")
      expect(json["body"]).to eq("公開本文")
      expect(json["status"]).to eq("published")
    end

    it "statusを指定しない場合は下書きとして作成される" do
      post "/api/v1/articles", params: {
        article: {
          title: "デフォルトタイトル",
          body: "デフォルト本文"
        }
      }.to_json,
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["status"]).to eq("draft")
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user, title: "Before", body: "Before body", status: :draft) }

    it "自分の記事を更新できる（下書きから公開に変更）" do
      patch "/api/v1/articles/#{article.id}", params: {
        article: { title: "After", body: "After body", status: "published" }
      }.to_json,
      headers: headers.merge({ 'Content-Type' => 'application/json' })

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("After")
      expect(json["body"]).to eq("After body")
      expect(json["status"]).to eq("published")
    end

    it "他人の記事は更新できない" do
      other_user = create(:user)
      other_article = create(:article, user: other_user)

      patch "/api/v1/articles/#{other_article.id}", params: {
        article: { title: "不正更新" }
      }.to_json,
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