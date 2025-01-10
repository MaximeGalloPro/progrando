class SubdomainMiddleware
    def initialize(app)
        @app = app
    end

    def call(env)
        request = Rack::Request.new(env)
        current_user = env['warden']&.user

        # TODO manage subdomain
        # if devise_route?(request.path) or !current_user
        #             return @app.call(env)
        #         end
        # current_organisation = set_current_organisation(current_user, request)
        # if current_user and current_organisation
        #     redirect_url = "http://#{current_organisation.slug}.localhost:3000#{request.path}"
        #     return [302, { 'Location' => redirect_url }, []]
        # end
        set_current_organisation(current_user, request)
        @app.call(env)
    end

    private

    def set_current_organisation(current_user, _request)
        Current.organisation = find_current_organisation(current_user)
    end

    def find_current_organisation(user)
        if user.current_organisation_id.present?
            Organisation.find_by(id: user.current_organisation_id)
        else
            user.organisations.first
            user.update_column(:current_organisation_id, user.organisations.first.id)
        end
        Organisation.find_by(id: user.current_organisation_id)
    end

    def devise_route?(path)
        path.start_with?('/users/sign_in',
                         '/users/sign_out',
                         '/users/password',
                         '/users/sign_up',
                         '/users/confirmation')
    end

    def extract_subdomain(host)
        return nil if host.nil?

        if host.include?('localhost')
            parts = host.split('.')
            return parts.first if parts.length > 1
            return nil
        end

        parts = host.split('.')
        return nil if parts.size <= 2
        subdomain = parts.first
        subdomain unless subdomain == 'www'
    end
end