require 'csv'
require 'date'

namespace :hike_histories do
    desc 'Import hike histories from CSV file'
    task import_histories: :environment do
        log_file = Rails.root.join('log', 'hike_histories_import.log')
        csv_file = Rails.root.join('lib', 'data', 'progrando_progs.csv')

        FRENCH_MONTHS = {
            'janvier' => 1,
            'février' => 2,
            'fevrier' => 2,
            'mars' => 3,
            'avril' => 4,
            'mai' => 5,
            'juin' => 6,
            'juillet' => 7,
            'août' => 8,
            'aout' => 8,
            'septembre' => 9,
            'octobre' => 10,
            'novembre' => 11,
            'décembre' => 12,
            'decembre' => 12
        }

        def parse_date(date_value)
            return nil if date_value.blank?

            # Si c'est déjà un objet Date, le retourner directement
            return date_value if date_value.is_a?(Date)

            # Si c'est une string, tenter la conversion
            begin
                Date.parse(date_value.to_s)
            rescue ArgumentError, TypeError => e
                puts "Error parsing date '#{date_value}': #{e.message}" # Debug
                nil
            end
        end

        def clean_number(str)
            return nil if str.blank?
            str.gsub(',', '.').strip
        end

        def convert_num(value)
            return nil if value.nil? || value.to_s.strip.empty?

            # Première tentative : conversion directe en integer
            begin
                return value.to_i
            rescue ArgumentError, TypeError
                # Continue si la conversion directe échoue
            end

            # Deuxième tentative : extraire uniquement les chiffres
            digits_only = value.to_s.gsub(/[^\d]/, '')

            # Vérifier si on a des chiffres après le nettoyage
            return digits_only.to_i if digits_only.present?

            # En dernier recours
            nil
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
                        carpooling_cost = convert_num(row['* C.V.'])
                        distance_km = convert_num(row['Kl'])
                        elevation_gain = convert_num(row['➚m'])

                        history = HikeHistory.find_or_initialize_by(
                            hiking_date: parse_date(hiking_date),
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

                        if history.save(validate: false)
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