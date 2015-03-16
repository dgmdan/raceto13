Rails.application.routes.draw do
  root 'application#home'

  resources :leagues do
    member do
      post 'join'
    end
  end

  resource :leagues

  resources :entries do
    collection do
      get 'index'
      post 'buy'
    end
  end

  devise_for :users
end
