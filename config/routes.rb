require 'sidekiq/web'

Rails.application.routes.draw do
  root 'application#home'

  get 'rules/:league_id' => 'application#rules'
  get 'rules' => 'application#rules'

  get 'console' => 'application#console'
  get 'test712' => 'application#test_email'

  resources :leagues do
    member do
      post 'join'
      get 'mass_email'
      post 'mass_email'
    end
  end

  get 'entries' => 'entries#index'
  get 'entries/:league_id' => 'entries#index', as: 'league_entries'
  resources :entries do
    collection do
      post 'buy'
    end

    member do
      post 'pay'
    end
  end

  get 'standings/:league_id' => 'standings#index', as: 'league_standings'
  get 'standings' => 'standings#index'

  resource :leagues

  get 'games' => 'games#index'
  resources :games do
    collection do
      get 'mass_entry'
      post 'mass_entry'
    end
  end

  devise_for :users, controllers: { registrations: 'registrations' }
  mount Sidekiq::Web => '/kiq712'
end
