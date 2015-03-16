Rails.application.routes.draw do
  root 'application#home'

  resources :leagues do
    member do
      post 'join'
    end
  end

  resources :entries do
    collection do
      get 'index'
      post 'buy'
    end
  end

  resources :standings do
    collection do
      get 'index'
    end
  end

  resource :leagues

  devise_for :users
end
