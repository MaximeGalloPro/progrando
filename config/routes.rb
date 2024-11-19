Rails.application.routes.draw do
  resources :hikes do
    member do
      post :refresh_from_openrunner
    end
  end
  resources :hike_histories
  get 'stats/dashboard', to: 'stats#dashboard'
end
