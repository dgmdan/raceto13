Rails.application.routes.draw do
  resources :leagues do
    member do
      post 'join'
    end
  end
  resource :leagues

  devise_for :users
end
