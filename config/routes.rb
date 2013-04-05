FeedasaurusRails::Application.routes.draw do
  root :to => 'feeds#index'

  resources :feeds, only: [:index, :show] do
    post :subscribe, on: :collection
    get :refresh, on: :member
  end
  resources :items, only: [:show]
  resources :groups, only: [:index]

  mount FeverAPI => '/api/fever'

end
