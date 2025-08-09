class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :username, :image, :avatar_url

  def name
    object.name || object.email&.split('@')&.first || 'Unknown'
  end

  def username
    object.name || object.email&.split('@')&.first || 'Unknown'
  end

  def image
    # プレースホルダー画像のパスを返す（実際の画像機能実装時に変更）
    nil
  end

  def avatar_url
    # プレースホルダー画像のパスを返す（実際の画像機能実装時に変更）
    nil
  end
end
