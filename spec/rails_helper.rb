# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# require_relative '../config/initializers/global_config'

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'capybara/rspec'
require 'shoulda/matchers'
require 'selenium-webdriver'

# Configuration pour Chrome Headless
Capybara.register_driver :selenium_chrome_headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')

    Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        options: options
    )
end

# Configuration de Capybara
Capybara.default_driver = :selenium_chrome_headless
Capybara.javascript_driver = :selenium_chrome_headless

begin
    ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
    puts e.to_s.strip
    exit 1
end

RSpec.configure do |config|
    # Configuration de base
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = true
    config.infer_spec_type_from_file_location!
    config.filter_rails_from_backtrace!

    # Factory Bot
    config.include FactoryBot::Syntax::Methods

    # Devise
    config.include Warden::Test::Helpers
    config.include Devise::Test::IntegrationHelpers, type: :system

    # Configuration Warden pour les tests
    config.before :suite do
        Warden.test_mode!
    end

    config.after :each do
        Warden.test_reset!
    end

    # Configuration des tests système
    config.before(:each, type: :system) do
        driven_by :selenium_chrome_headless
    end
end

# Configuration Shoulda Matchers
Shoulda::Matchers.configure do |config|
    config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
    end
end