# frozen_string_literal: true

class ApplicationController < ActionController::Base
    include AuthorizationConcern
    include SubdomainRedirection

    helper_method :browser

    private

    def browser
        @browser ||= Browser.new(request.user_agent)
    end
end
