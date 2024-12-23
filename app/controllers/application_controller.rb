class ApplicationController < ActionController::Base
    include AuthorizationConcern
    set_current_tenant_through_filter
    before_action :set_current_tenant

    helper_method :browser

    private

    def browser
        @browser ||= Browser.new(request.user_agent)
    end

    def set_current_tenant
        # Si on est sur localhost sans sous-domaine
        if request.subdomain.blank? || request.subdomain == 'www'
            default_org = Organization.first
            if default_org
                # Rediriger vers le sous-domaine du premier tenant
                redirect_to(
                    "#{request.protocol}#{default_org.subdomain}.#{request.domain}#{":#{request.port}" if request.port}#{request.path}",
                    allow_other_host: true
                )
                return
            end
        end

        begin
            current_organization = Organization.find_by!(subdomain: request.subdomain)
            set_current_tenant(current_organization)
        rescue ActiveRecord::RecordNotFound
            redirect_to root_path, alert: "Organisation non trouvée"
        end
    end
end