Rails.application.routes.draw do
  root 'application#home'
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
  resources :entries do
    collection do
      post 'buy'
    end

    member do
      post 'pay'
    end
  end

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
end
