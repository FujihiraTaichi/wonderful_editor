class Api::V1::ArticlePreviewSerializer < ActiveModel::Serializer
  attributes :id, :title, :updated_at, :image, :thumbnail, :cover
  has_one :user, serializer: Api::V1::UserSerializer

  def image
    # プレースホルダー画像のパスを返す（実際の画像機能実装時に変更）
    nil
  end

  def thumbnail
    # プレースホルダー画像のパスを返す（実際の画像機能実装時に変更）
    nil
  end

  def cover
    # プレースホルダー画像のパスを返す（実際の画像機能実装時に変更）
    nil
  end
end