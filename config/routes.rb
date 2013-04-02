FeedasaurusRails::Application.routes.draw do
  root :to => 'feeds#index'

  resources :groups, only: [:index]
  resources :feeds, only: [:index, :show, :create] do
    member do
      get :refresh
    end
  end
  resources :items, only: [:show]

  mount FeverAPI => '/api/fever'

end
