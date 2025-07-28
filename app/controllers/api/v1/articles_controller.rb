class Api::V1::ArticlesController < Api::V1::BaseApiController
  before_action :authenticate_api_v1_user!, only: [:create, :update, :destroy]
  before_action :set_article, only: [:show, :update, :destroy]

  def index
    articles = Article.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  def create
    article = current_user.articles.build(article_params)
    if article.save
      render json: article, status: :created
    else
      render json: { errors: article.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    article = Article.find(params[:id])
    if article.user_id != current_user.id
      render json: { error: "You are not authorized to update this article" }, status: :forbidden
      return
    end

    if article.update(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer, status: :ok
    else
      render json: { errors: article.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    if @article.user_id == current_user.id
      @article.destroy
      head :no_content
    else
      render json: { error: "権限がありません" }, status: :forbidden
    end
  end

  private

  def article_params
    params.require(:article).permit(:title, :body)
  end

  def set_article
    @article = Article.find_by(id: params[:id])
    unless @article
      render json: { error: "記事が見つかりません" }, status: :not_found
    end
  end
end