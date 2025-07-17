class Api::V1::BaseApiController < ApplicationController
  protect_from_forgery with: :null_session
end