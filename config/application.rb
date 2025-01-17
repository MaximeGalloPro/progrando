# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
require_relative '../app/middleware/subdomain_middleware'

Bundler.require(*Rails.groups)

module Rails7WithDocker
    # Main application class for Rails7WithDocker
    # Configures core application settings including middleware and job processing
    class Application < Rails::Application
        # Initialize configuration defaults for originally generated Rails version.
        config.load_defaults 7.0
        config.active_job.queue_adapter = :sidekiq
        config.middleware.use SubdomainMiddleware
        config.i18n.default_locale = :fr
        config.i18n.available_locales = %i[fr en]
    end
end
