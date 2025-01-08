class ApplicationController < ActionController::Base
    include AuthorizationConcern
    include SubdomainRedirection

    helper_method :browser
    # before_action :ensure_organisation_present, unless: :devise_controller?
    # before_action :set_current_organisation, unless: :devise_controller?

    private

    def browser
        @browser ||= Browser.new(request.user_agent)
    end

    # def set_current_organisation
    #     Current.organisation = current_user&.organisation
    # end

    # def ensure_organisation_present
    #     unless Current.organisation.present?
    #         redirect_to main_app.root_url(subdomain: nil),
    #                     alert: "Organisation non trouvée"
    #     end
    # end
end