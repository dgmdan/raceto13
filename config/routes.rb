require 'sidekiq/web'

Rails.application.routes.draw do
  # home
  root 'application#home'

  # rules
  get 'rules/:league_id' => 'application#rules'
  get 'rules' => 'application#rules'

  # leagues/invites
  get 'invite/:invite_uuid' => 'leagues#invite', as: 'invite', constraints: { invite_uuid: /[\w\d\-]+/ }
  resource :leagues
  resources :leagues do
    member do
      get 'mass_email'
      post 'mass_email'
    end
  end

  # entries
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

  # standings
  get 'standings/:league_id' => 'standings#index', as: 'league_standings'
  get 'standings' => 'standings#index'

  # games
  get 'games' => 'games#index'
  resources :games do
    collection do
      get 'mass_entry'
      post 'mass_entry'
    end
  end

  # authentication
  devise_for :users, controllers: { registrations: 'registrations' }

  # rails console
  get 'console' => 'application#console'

  # test sending email
  get 'test712' => 'application#test_email'

  # sidekiq monitoring
  mount Sidekiq::Web => '/kiq712'
end
