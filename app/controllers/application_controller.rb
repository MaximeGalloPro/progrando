class ApplicationController < ActionController::Base
    include AuthorizationConcern

    helper_method :browser

    private

    def browser
        @browser ||= Browser.new(request.user_agent)
    end
end
