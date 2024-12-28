# app/controllers/concerns/subdomain_redirection.rb
module SubdomainRedirection
    extend ActiveSupport::Concern

    included do
        before_action :handle_sign_in_subdomain
    end

    private

    def handle_sign_in_subdomain
        return unless devise_controller? && action_name == 'new' && controller_name == 'sessions'

        subdomain = request.subdomains.first
        if subdomain.present?
            redirect_to new_user_session_url(subdomain: nil), allow_other_host: true
        end
    end
end