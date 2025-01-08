require 'colorize'

class SubdomainMiddleware
    def initialize(app)
        @app = app
        puts "\n[MIDDLEWARE] Initializing SubdomainMiddleware".yellow
    end

    def call(env)
        request = Rack::Request.new(env)
        current_user = env['warden']&.user
        subdomain = extract_subdomain(request.host)

        log_request_info(request, subdomain, current_user)

        if subdomain.present?
            handle_subdomain_request(env, request, current_user, subdomain)
        else
            handle_main_domain_request(env, request, current_user)
        end
    end

    private

    def handle_subdomain_request(env, request, current_user, subdomain)
        return handle_unauthenticated_subdomain(request) unless current_user
        return @app.call(env) if devise_route?(request.path)

        organisation = find_organisation(current_user, subdomain)

        if organisation
            setup_organisation_context(env, organisation)
            @app.call(env)
        else
            handle_unauthorised_access(env)
        end
    end

    def handle_main_domain_request(env, request, current_user)
        Current.organisation = nil
        @app.call(env)
    end

    def handle_unauthenticated_subdomain(request)
        return @app.call(env) if devise_route?(request.path)
        redirect_to_login(request)
    end

    def setup_organisation_context(env, organisation)
        puts "[ACCESS] Authorizing access to organisation: #{organisation.name} (ID: #{organisation.id})".green
        Current.organisation = organisation
        env['rack.session'] ||= {}
        env['rack.session']['current_organisation_id'] = organisation.id
    end

    def find_organisation(current_user, subdomain)
        current_user.organisations.find_by(slug: subdomain)
    end

    def handle_unauthorised_access(env)
        puts "[ACCESS] Access denied - Organisation not found or unauthorized".red
        env['warden'].logout
        flash_message = CGI.escape('{"alert":"You do not have access to this organization"}')
        [302, {
            'Location' => '/',
            'Set-Cookie' => "flash=#{flash_message}"
        }, []]
    end

    def redirect_to_login(request)
        main_domain = request.host.split('.')[1..-1].join('.')
        url = "http://#{main_domain}:#{request.port}/users/sign_in"
        puts "[REDIRECT] Redirecting to: #{url}".red
        [301, {'Location' => url}, []]
    end

    def devise_route?(path)
        devise_paths = [
            '/users/sign_in',
            '/users/sign_out',
            '/users/password',
            '/users/sign_up',
            '/users/confirmation'
        ]
        is_devise = path.start_with?(*devise_paths)
        puts "[ROUTE] Checking Devise route: #{is_devise}".yellow if is_devise
        is_devise
    end

    def extract_subdomain(host)
        return nil if host.nil?

        subdomain = if host.include?('localhost')
                        parts = host.split('.')
                        parts.length > 1 ? parts.first : nil
                    else
                        parts = host.split('.')
                        parts.size <= 2 ? nil : (parts.first unless parts.first == 'www')
                    end

        puts "[SUBDOMAIN] Extracted subdomain: #{subdomain || 'none'}".blue
        subdomain
    end

    def log_request_info(request, subdomain, current_user)
        puts "\n#{'='*50}".blue
        puts "[REQUEST] Host: #{request.host}".green
        puts "[REQUEST] Path: #{request.path}".green
        puts "[REQUEST] Extracted subdomain: #{subdomain || 'none'}".green
        puts "[USER] #{current_user ? "Logged in (ID: #{current_user.id})" : 'Not logged in'}".green
        puts "#{'='*50}\n".blue
    end
end