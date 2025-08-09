Rails.application.routes.draw do
  root to: "home#index"

  # SPA のためのリロード対策
  get "sign_up",               to: "home#index"
  get "sign_in",               to: "home#index"
  get "articles/new",          to: "home#index"
  get "articles/draft",        to: "home#index"
  get "articles/drafts/:id/edit", to: "home#index"
  get "articles/:id/edit",     to: "home#index"
  get "articles/:id",          to: "home#index"
  get "mypage",                to: "home#index"

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for "User", at: "auth", controllers: {
        registrations: "api/v1/auth/registrations",
      }

      # 下書きAPI: /api/v1/articles/drafts(:id)
      namespace :articles do
        resources :drafts, only: [:index, :show]
      end

      namespace :current do
        resources :articles, only: [:index]
      end

      resources :articles
    end
  end
end