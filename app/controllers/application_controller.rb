class ApplicationController < ActionController::Base
    include AuthorizationConcern

    helper_method :current_organization
    before_action :ensure_organization

    private

    def current_organization
        Rails.logger.info "=== URL Debug Information ==="
        Rails.logger.info "Full URL: #{request.url}"
        Rails.logger.info "Host with Port: #{request.host_with_port}"
        Rails.logger.info "Host: #{request.host}"
        Rails.logger.info "Subdomain: #{request.subdomain}"
        Rails.logger.info "Domain: #{request.domain}"
        Rails.logger.info "Protocol: #{request.protocol}"
        Rails.logger.info "=========================="
        @current_organization ||= Organization.find_by(subdomain: request.subdomain)
    end

    def ensure_organization
        return if request.subdomain.blank?

        unless current_organization
            redirect_to root_url(subdomain: nil),
                        alert: "Organisation non trouvée"
        end
    end
end