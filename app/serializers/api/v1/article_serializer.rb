class Api::V1::ArticleSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :updated_at
  belongs_to :user

  class UserSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end