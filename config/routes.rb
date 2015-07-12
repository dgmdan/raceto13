Rails.application.routes.draw do
  root 'application#home'

  resources :leagues do
    member do
      post 'join'
			get 'mass_email'
			post 'mass_email'
    end
  end

  resources :entries do
    collection do
      get 'index'
      post 'buy'
    end

    member do
      post 'pay'
    end
  end

  resources :standings do
    collection do
      get 'index'
    end
  end

  resource :leagues

  resources :games do
    collection do
      get 'index'
      get 'mass_entry'
      post 'mass_entry'
    end
  end

  devise_for :users
end
