# frozen_string_literal: true

# Base controller for the application, providing common functionality across
# all controllers. Includes authorization management, subdomain handling,
# and browser detection capabilities.
class ApplicationController < ActionController::Base
    include AuthorizationConcern
    include SubdomainRedirection

    helper_method :browser

    private

    def browser
        @browser ||= Browser.new(request.user_agent)
    end
end
