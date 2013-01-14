FeedasaurusRails::Application.routes.draw do
  root :to => 'feeds#index'

  resources :groups
  resources :feeds do
    member do
      get :refresh
    end
  end
  resources :items, only: [:show]

end
