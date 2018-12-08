Rails.application.routes.draw do
  root to: 'pages#home'

  namespace :client do
    resources :orders
  end
end
