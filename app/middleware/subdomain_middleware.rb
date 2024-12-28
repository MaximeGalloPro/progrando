class SubdomainMiddleware
    def initialize(app)
        @app = app
    end

    def call(env)
        request = Rack::Request.new(env)
        current_user = env['warden']&.user

        # Si c'est une route Devise, on laisse passer
        if devise_route?(request.path)
            return @app.call(env)
        end

        subdomain = extract_subdomain(request.host)

        # Si l'utilisateur est connecté et qu'il y a un sous-domaine qui ne correspond pas
        if current_user && subdomain.present?
            organisation = Organisation.find_by(slug: subdomain)
            if organisation && current_user.organisation_id != organisation.id
                # Déconnecter l'utilisateur
                env['warden'].logout
                # Créer un cookie de flash message
                flash_cookie = "flash=%7B%22alert%22%3A%22Vous+n%27avez+pas+acc%C3%A8s+%C3%A0+cette+organisation%22%7D"
                begin
                    url = "http://#{current_user.organisation.slug}.localhost:3000#{request.path}"
                rescue
                    url = "http://localhost:3000/users/sign_in"
                end
                return [302, {
                    'Location' => url,
                    'Set-Cookie' => flash_cookie
                }, []]
            elsif organisation && current_user.organisation_id == organisation.id
                Current.organisation = organisation
                return @app.call(env)
            end
        end

        # Si l'utilisateur est connecté mais n'a pas de sous-domaine, rediriger vers son organisation
        if current_user && !subdomain && current_user.organisation
            redirect_url = "http://#{current_user.organisation.slug}.localhost:3000#{request.path}"
            return [302, { 'Location' => redirect_url }, []]
        end

        # Si pas d'utilisateur connecté
        if !current_user
            Current.organisation = nil
            return @app.call(env)
        end

        @app.call(env)
    end

    private

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