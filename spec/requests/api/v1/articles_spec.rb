require 'rails_helper'

RSpec.describe "Api::V1::Articles", type: :request do
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
end