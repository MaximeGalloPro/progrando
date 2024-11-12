Rails.application.routes.draw do
  resources :hikes
  resources :hike_histories
  get 'stats/dashboard', to: 'stats#dashboard'
end
