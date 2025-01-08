Rails.application.routes.draw do
    # Routes en dehors des contraintes
    devise_for :users
    resources :organisations do
        post :switch, on: :member
        resources :profiles do
            resources :profile_rights do
                member do
                    patch :toggle_authorization
                end
            end
        end
    end

    # Routes avec contraintes d'organisation
    constraints lambda { |req| Current.organisation.present? } do
        root to: 'stats#dashboard', as: :authenticated_root

        patch 'users/theme', to: 'users#update_theme', as: :update_user_theme
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

    root to: lambda { |_|
        if Current.organisation.present?
            '/stats/dashboard'
        else
            '/users/sign_in'
        end
    }

    get '/404', to: 'errors#not_found'
end