Rails.application.routes.draw do
  resources :maps
  resources :guides
  resources :hikes do
    member do
      post :refresh_from_openrunner
    end
    collection do
      get :fetch_openrunner_details
    end
  end
  resources :hike_histories
  get 'stats/dashboard', to: 'stats#dashboard'
end
