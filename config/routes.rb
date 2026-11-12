Rails.application.routes.draw do
  root "posts#index"

  resources :posts
  post "articles/attach", to: "posts#attach", as: :attach_image

  # カテゴリー（タグ）一覧と、タグごとの記事一覧
  get "categories", to: "posts#categories"
  resources :tags, only: [] do
    get "posts", to: "posts#search"
  end

  # 管理者ログイン
  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # 死活監視用（正常なら 200 を返す）
  get "up", to: "rails/health#show", as: :rails_health_check
end
