require 'csv'
require 'date'

namespace :hike_histories do
    desc 'Import hike histories from CSV file'
    task import_histories: :environment do
        log_file = Rails.root.join('log', 'hike_histories_import.log')
        csv_file = Rails.root.join('lib', 'data', 'progrando_progs.csv')

        def parse_date(date_str)
            return nil if date_str.blank?
            # Format attendu : "mardi, janvier 02, 2018"
            Date.parse(date_str) rescue nil
        end

        def clean_number(str)
            return nil if str.blank?
            str.gsub(',', '.').strip
        end

        File.open(log_file, 'a') do |log|
            log.puts "\n=== Import started at #{Time.current} ==="

            begin
                rows = CSV.read(csv_file,
                                headers: true,
                                encoding: 'utf-8',
                                col_sep: ',')

                rows.each do |row|
                    begin
                        # Utilise uniquement la colonne "Dates" pour hiking_date
                        hiking_date = parse_date(row['Dates'])

                        unless hiking_date
                            log.puts "Skipping row: Invalid date format in Dates column: #{row['Dates']}"
                            next
                        end

                        # Clean numbers
                        carpooling_cost = clean_number(row['* C.V.'])
                        distance_km = clean_number(row['Kl'])
                        elevation_gain = clean_number(row['➚m'])

                        history = HikeHistory.find_or_initialize_by(
                            hiking_date: hiking_date,
                            hike_number: row['N°']
                        )

                        history.assign_attributes(
                            departure_time: row['Depart']&.strip,
                            day_type: row['Journee']&.strip,
                            difficulty: row['Dif.'],
                            starting_point: row['Depart de la randonnee']&.strip,
                            trail_name: row['Parcours']&.strip,
                            carpooling_cost: carpooling_cost,
                            distance_km: distance_km,
                            elevation_gain: elevation_gain,
                            guide_name: row['Animateur']&.strip,
                            guide_phone: row['Tel.']&.strip,
                            openrunner_ref: row['Ref']&.strip
                        )

                        if history.save
                            log.puts "Successfully imported history for hike ##{history.hike_number} on #{history.hiking_date}"
                        else
                            log.puts "Error importing history for hike ##{row['N°']}: #{history.errors.full_messages.join(', ')}"
                        end
                    rescue StandardError => e
                        log.puts "Error processing row: #{e.message}"
                        puts e.message # Pour debug
                    end
                end

            rescue StandardError => e
                log.puts "Fatal error during import: #{e.message}"
                log.puts e.backtrace
                puts e.message # Pour debug
            end

            log.puts "=== Import finished at #{Time.current} ==="
        end
    end
end