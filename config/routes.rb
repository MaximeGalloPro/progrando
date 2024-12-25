# config/routes.rb
Rails.application.routes.draw do
    constraints ->(req) { req.subdomain.blank? } do
        get '/', to: redirect { |_params, req|
            org = Organization.first
            "#{req.protocol}#{org.subdomain}.#{req.host}:#{req.port}"
        }
    end

    constraints ->(req) { req.subdomain.present? } do
        get '/', to: 'stats#dashboard', as: :tenant_root
        devise_for :users
        patch 'users/theme', to: 'users#update_theme', as: :update_user_theme

        resources :rights
        resources :hike_paths do
            collection do
                get :map
            end
        end
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
end