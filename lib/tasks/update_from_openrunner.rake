require 'capybara'
require 'selenium-webdriver'

namespace :hikes do
    desc "Update hike details from Openrunner using Capybara"
    task update_details: :environment do
        puts "🚀 Démarrage de la mise à jour des randonnées..."

        # Configuration de Capybara
        Capybara.default_driver = :selenium_headless
        Capybara.javascript_driver = :selenium_headless
        Capybara.app_host = 'https://www.openrunner.com'

        browser = Capybara::Session.new(:selenium_headless)

        # On prend toutes les randonnées
        hikes_to_update = Hike.all
        total_hikes = hikes_to_update.count
        puts "📋 #{total_hikes} randonnée(s) à traiter"

        success_count = 0
        error_count = 0
        skipped_count = 0

        hikes_to_update.find_each.with_index(1) do |hike, index|
            puts "\n✨ Traitement de la randonnée #{index}/#{total_hikes}: #{hike.trail_name}"

            begin
                puts "🔗 Visite de #{hike.openrunner_url}"
                browser.visit(hike.openrunner_url)

                # Attendre que les données soient chargées
                sleep 5

                puts "🔍 Recherche des données..."

                # Extraction de toutes les données
                updates = {}

                begin
                    distance_element = browser.find('.or-parcours-info-block', text: 'Distance')
                    distance = distance_element.find('.or-parcours-info-text').text.gsub(',', '.').to_f
                    updates[:distance_km] = distance
                    puts "📏 Distance trouvée: #{distance} km"
                rescue Capybara::ElementNotFound
                    puts "⚠️ Distance non trouvée"
                end

                begin
                    elevation_plus_element = browser.find('.or-parcours-info-block', text: 'Dénivelé +')
                    elevation_plus = elevation_plus_element.find('.or-parcours-info-text').text.to_i
                    updates[:elevation_gain] = elevation_plus
                    puts "⛰️ Dénivelé + trouvé: #{elevation_plus} m"
                rescue Capybara::ElementNotFound
                    puts "⚠️ Dénivelé + non trouvé"
                end

                begin
                    elevation_minus_element = browser.find('.or-parcours-info-block', text: 'Dénivelé -')
                    elevation_minus = elevation_minus_element.find('.or-parcours-info-text').text.to_i
                    updates[:elevation_loss] = elevation_minus
                    puts "⛰️ Dénivelé - trouvé: #{elevation_minus} m"
                rescue Capybara::ElementNotFound
                    puts "⚠️ Dénivelé - non trouvé"
                end

                begin
                    altitude_min_element = browser.find('.or-parcours-info-block', text: 'Altitude min.')
                    altitude_min = altitude_min_element.find('.or-parcours-info-text').text.to_i
                    updates[:altitude_min] = altitude_min
                    puts "📉 Altitude min trouvée: #{altitude_min} m"
                rescue Capybara::ElementNotFound
                    puts "⚠️ Altitude min non trouvée"
                end

                begin
                    altitude_max_element = browser.find('.or-parcours-info-block', text: 'Altitude max.')
                    altitude_max = altitude_max_element.find('.or-parcours-info-text').text.to_i
                    updates[:altitude_max] = altitude_max
                    puts "📈 Altitude max trouvée: #{altitude_max} m"
                rescue Capybara::ElementNotFound
                    puts "⚠️ Altitude max non trouvée"
                end

                # Mise à jour de la randonnée si on a trouvé au moins une donnée
                if updates.any?
                    if hike.update(updates)
                        puts "✅ Mise à jour réussie avec: #{updates}"
                        success_count += 1
                    else
                        puts "⚠️ Échec de la mise à jour: #{hike.errors.full_messages.join(', ')}"
                        error_count += 1
                    end
                else
                    puts "⚠️ Aucune donnée trouvée"
                    skipped_count += 1
                end

                # Pause pour ne pas surcharger le serveur
                puts "⏳ Pause de 2 secondes..."
                sleep 2

            rescue StandardError => e
                puts "❌ Erreur pour #{hike.trail_name}: #{e.message}"
                puts "   #{e.backtrace.first(3).join("\n   ")}"
                error_count += 1
            end
        end

        # Fermeture du navigateur
        browser.quit

        puts "\n📊 Résumé de la mise à jour:"
        puts "✅ Succès: #{success_count}"
        puts "❌ Erreurs: #{error_count}"
        puts "⏭️ Ignorés: #{skipped_count}"
        puts "🏁 Total traité: #{total_hikes}"
    end
end