# lib/tasks/import_hikes.rake
require 'csv'

namespace :hikes do
    desc 'Import hikes from CSV file'
    task import: :environment do
        log_file = Rails.root.join('log', 'hikes_import.log')
        csv_file = Rails.root.join('lib', 'data', 'progrando_hikes.csv')

        File.open(log_file, 'a') do |log|
            log.puts "\n=== Import started at #{Time.current} ==="

            begin
                rows = CSV.read(csv_file,
                                headers: true,
                                encoding: 'utf-8',
                                col_sep: ',')

                puts "Headers found: #{rows.headers.inspect}" # Pour debug

                rows.each do |row|
                    begin
                        last_schedule = Date.strptime(row['Dernier Prog'], '%d/%m/%Y') rescue nil

                        hike = Hike.find_or_initialize_by(number: row['Numero'])
                        hike.assign_attributes(
                            day: row['D'],
                            difficulty: row['Dif.'],
                            starting_point: row['Depart de la randonnee'],
                            trail_name: row['Parcours'],
                            carpooling_cost: row['C.V. *'],
                            distance_km: row['Kl'],
                            elevation_gain: row['m'],
                            openrunner_ref: row['Ref Openrunner'],
                            last_schedule: last_schedule
                        )

                        if hike.save
                            log.puts "Successfully imported hike ##{hike.number}"
                        else
                            log.puts "Error importing hike ##{row['Numero']}: #{hike.errors.full_messages.join(', ')}"
                        end
                    rescue StandardError => e
                        log.puts "Error processing row #{row['Numero']}: #{e.message}"
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