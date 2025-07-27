class Api::V1::ArticlesController < Api::V1::BaseApiController
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

  private

  def article_params
    params.require(:article).permit(:title, :body)
  end
end