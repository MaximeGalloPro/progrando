Rails.application.routes.draw do
    devise_for :users

    patch 'users/theme', to: 'users#update_theme', as: :update_user_theme

    root to: 'stats#dashboard'
    resources :rights
    resources :hike_paths do
        collection do
            get :map
        end
    end
    resources :guides
    resources :members
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

    get '/health', to: proc { [200, {}, ['OK']] }
end
