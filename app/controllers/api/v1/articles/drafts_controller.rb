# frozen_string_literal: true
module Api
  module V1
    module Articles
      class DraftsController < Api::V1::BaseApiController
        before_action :authenticate_user!

        # GET /api/v1/articles/drafts
        def index
          articles = current_user.articles.draft.order(updated_at: :desc)
          render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
        end

        # GET /api/v1/articles/drafts/:id
        def show
          article = current_user.articles.draft.find(params[:id])
          render json: article, serializer: Api::V1::ArticleSerializer
        rescue ActiveRecord::RecordNotFound
          render json: { error: '下書き記事が見つかりません' }, status: :not_found
        end
      end
    end
  end
end
