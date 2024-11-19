# app/jobs/update_hike_from_openrunner_job.rb
require 'capybara'
require 'selenium-webdriver'

class UpdateHikeFromOpenrunnerJob < ApplicationJob
    queue_as :default

    def perform(hike)
        # Configuration de Capybara pour chaque job
        Capybara.default_driver = :selenium_headless
        Capybara.javascript_driver = :selenium_headless
        Capybara.app_host = 'https://www.openrunner.com'

        browser = Capybara::Session.new(:selenium_headless)

        begin
            puts "🔗 Mise à jour de la randonnée #{hike.trail_name}"
            browser.visit(hike.openrunner_url)
            sleep 5

            updates = {}

            begin
                distance_element = browser.find('.or-parcours-info-block', text: 'Distance')
                distance = distance_element.find('.or-parcours-info-text').text.gsub(',', '.').to_f
                updates[:distance_km] = distance
            rescue Capybara::ElementNotFound
            end

            begin
                elevation_plus_element = browser.find('.or-parcours-info-block', text: 'Dénivelé +')
                elevation_plus = elevation_plus_element.find('.or-parcours-info-text').text.to_i
                updates[:elevation_gain] = elevation_plus
            rescue Capybara::ElementNotFound
            end

            begin
                elevation_minus_element = browser.find('.or-parcours-info-block', text: 'Dénivelé -')
                elevation_minus = elevation_minus_element.find('.or-parcours-info-text').text.to_i
                updates[:elevation_loss] = elevation_minus
            rescue Capybara::ElementNotFound
            end

            begin
                altitude_min_element = browser.find('.or-parcours-info-block', text: 'Altitude min.')
                altitude_min = altitude_min_element.find('.or-parcours-info-text').text.to_i
                updates[:altitude_min] = altitude_min
            rescue Capybara::ElementNotFound
            end

            begin
                altitude_max_element = browser.find('.or-parcours-info-block', text: 'Altitude max.')
                altitude_max = altitude_max_element.find('.or-parcours-info-text').text.to_i
                updates[:altitude_max] = altitude_max
            rescue Capybara::ElementNotFound
            end

            if updates.any?
                hike.update(updates)
                puts "✅ Mise à jour réussie avec: #{updates}"
            end

        ensure
            browser.quit
        end
    end
end