class ApplicationController < ActionController::Base
    include AuthorizationConcern

    helper_method :browser

    before_action :set_current_organisation

    private

    def browser
        @browser ||= Browser.new(request.user_agent)
    end

    def set_current_organisation
        Current.organisation = current_user&.organisation
    end
end
