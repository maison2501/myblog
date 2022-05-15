Rails.application.routes.draw do
  root to: 'posts#index'
  resources :posts
  post 'articles/attach', to: 'posts#attach'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
