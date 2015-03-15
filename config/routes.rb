Rails.application.routes.draw do
  root 'application#home'

  resources :leagues do
    member do
      post 'join'
      post 'update_teams'
    end
  end
  resource :leagues

  devise_for :users
end
