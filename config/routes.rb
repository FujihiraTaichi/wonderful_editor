Rails.application.routes.draw do
  root to: "home#index"

  # reload 対策
  get "sign_up", to: "home#index"
  get "sign_in", to: "home#index"
  get "articles/new", to: "home#index"
  get "articles/:id", to: "home#index"

  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for "User", at: "auth"

      resources :articles do
        collection do
          get :drafts
        end
      end

      # 下書き記事の詳細取得用のルート
      get 'articles/drafts/:id', to: 'articles#show_draft'

      # マイページ用のルート
      get 'current/articles', to: 'articles#my_published_articles'
    end
  end
end
