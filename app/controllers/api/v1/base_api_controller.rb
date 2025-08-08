class Api::V1::BaseApiController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken  # ←これ入ってる？
  # protect_from_forgery with: :null_session           # APIならこれ or skip_before_action
  # protect_from_forgery with: :null_session

  # Expose devise_token_auth helpers with generic names in API layer
  def current_user
    current_api_v1_user
  end

  def authenticate_user!
    authenticate_api_v1_user!
  end

  def user_signed_in?
    api_v1_user_signed_in?
  end
end