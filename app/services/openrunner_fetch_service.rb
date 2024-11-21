# app/services/openrunner_fetch_service.rb
require 'capybara'
require 'selenium-webdriver'

class OpenrunnerFetchService
    def self.fetch_details(openrunner_ref)
        puts "\n🚀 Starting OpenrunnerFetchService for ref: #{openrunner_ref}"
        new(openrunner_ref).fetch_details
    end

    def initialize(openrunner_ref)
        @openrunner_ref = openrunner_ref
        @url = "https://www.openrunner.com/route-details/#{openrunner_ref}"
        puts "📌 Initialized with URL: #{@url}"
    end

    def fetch_details
        puts "\n🔧 Setting up Capybara..."
        setup_capybara
        puts "🔍 Starting data fetch..."
        result = fetch_data
        puts "✅ Fetch completed successfully"
        puts "📊 Retrieved data: #{result.inspect}"
        result
    rescue StandardError => e
        puts "❌ Error occurred: #{e.class}"
        puts "❌ Error message: #{e.message}"
        puts "❌ Backtrace: #{e.backtrace.join("\n")}"
        { error: e.message }
    ensure
        if @browser
            puts "🧹 Cleaning up browser session..."
            @browser.quit
            puts "👋 Browser session closed"
        end
    end

    private

    def setup_capybara
        puts "🔧 Configuring Capybara drivers..."
        Capybara.default_driver = :selenium_headless
        Capybara.javascript_driver = :selenium_headless
        Capybara.app_host = 'https://www.openrunner.com'

        puts "🌐 Creating new browser session..."
        @browser = Capybara::Session.new(:selenium_headless)
        puts "✅ Capybara setup completed"
    end

    def fetch_data
        puts "\n🌐 Visiting URL: #{@url}"
        @browser.visit(@url)
        puts "⏳ Waiting 5 seconds for page load..."
        sleep 5
        puts "✅ Page loaded"

        result = {}

        # Liste des éléments à récupérer
        elements_to_fetch = {
            distance_km: ['Distance', :to_f],
            elevation_gain: ['Dénivelé +', :to_i],
            elevation_loss: ['Dénivelé -', :to_i],
            altitude_min: ['Altitude min.', :to_i],
            altitude_max: ['Altitude max.', :to_i]
        }

        puts "\n🔍 Starting to fetch elements..."
        elements_to_fetch.each do |key, (text, conversion)|
            puts "\n👉 Fetching #{key}..."
            value = fetch_element(text, conversion)
            if value
                result[key] = value
                puts "✅ Found #{key}: #{value}"
            else
                puts "⚠️ Could not find #{key}"
            end
        end

        puts "\n📊 Final data collected:"
        result.each { |k, v| puts "  #{k}: #{v}" }

        result.compact
    end

    def fetch_element(text, conversion_method)
        puts "  🔍 Looking for element with text: '#{text}'"

        element = @browser.find('.or-parcours-info-block', text: text)
        puts "  ✅ Found block element for '#{text}'"

        value_element = element.find('.or-parcours-info-text')
        puts "  ✅ Found value element"

        raw_value = value_element.text
        puts "  📝 Raw value: #{raw_value}"

        cleaned_value = raw_value.gsub(',', '.')
        puts "  🧹 Cleaned value: #{cleaned_value}"

        final_value = cleaned_value.send(conversion_method)
        puts "  🎯 Converted value: #{final_value}"

        final_value
    rescue Capybara::ElementNotFound => e
        puts "  ⚠️ Element not found: #{e.message}"
        nil
    rescue StandardError => e
        puts "  ❌ Other error while fetching element: #{e.message}"
        nil
    end

    def log_page_content
        puts "\n📄 Current page content:"
        puts "URL: #{@browser.current_url}"
        puts "Title: #{@browser.title}"
        puts "Body text preview: #{@browser.text[0..200]}..."
        puts "\n📄 Page source preview:"
        puts @browser.html[0..500]
    rescue StandardError => e
        puts "❌ Error while logging page content: #{e.message}"
    end
end