Rails.application.routes.draw do
  root to: 'posts#index'
  resources :posts
  post 'articles/attach', to: 'posts#attach'
  resources :tags do
    get 'posts', to: 'posts#search'
  end
  get 'categories', to: 'posts#categories'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
