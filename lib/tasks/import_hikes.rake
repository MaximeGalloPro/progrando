# frozen_string_literal: true

# lib/tasks/import_hikes.rake
require 'csv'

namespace :hikes do
    desc 'Import hikes from CSV file'
    task import: :environment do
        HikesImporter.new.import
    end
end

# lib/services/hikes_importer.rb
class HikesImporter
    def initialize
        @log_file = Rails.root.join('log/hikes_import.log')
        @csv_file = Rails.root.join('lib/data/progrando_hikes.csv')
    end

    def import
        File.open(@log_file, 'a') do |log|
            log_import_process(log) { process_csv_file(log) }
        end
    end

    private

    def log_import_process(log)
        log.puts "\n=== Import started at #{Time.current} ==="
        yield
        log.puts "=== Import finished at #{Time.current} ==="
    rescue StandardError => e
        log.puts "Fatal error during import: #{e.message}"
        log.puts e.backtrace
        puts e.message # Pour debug
    end

    def process_csv_file(log)
        rows = read_csv_file
        puts "Headers found: #{rows.headers.inspect}" # Pour debug
        process_rows(rows, log)
    end

    def read_csv_file
        CSV.read(@csv_file,
                 headers: true,
                 encoding: 'utf-8',
                 col_sep: ',')
    end

    def process_rows(rows, log)
        rows.each { |row| process_row(row, log) }
    end

    def process_row(row, log)
        hike = create_or_update_hike(row)
        log_result(hike, row, log)
    rescue StandardError => e
        log.puts "Error processing row #{row['Numero']}: #{e.message}"
        puts e.message # Pour debug
    end

    def create_or_update_hike(row)
        hike = Hike.find_or_initialize_by(number: row['Numero'])
        hike.assign_attributes(hike_attributes(row))
        hike.save
        hike
    end

    def hike_attributes(row)
        {
            day: row['D'],
            difficulty: row['Dif.'] || 1,
            starting_point: row['Depart de la randonnee'],
            trail_name: row['Parcours'],
            carpooling_cost: convert_num(row['C.V. *']),
            distance_km: convert_num(row['Kl']),
            elevation_gain: convert_num(row['m']),
            openrunner_ref: convert_num(row['Ref Openrunner']) || 0
        }
    end

    def log_result(hike, row, log)
        if hike.persisted?
            log.puts "Successfully imported hike ##{hike.number}"
        else
            log.puts "Error importing hike ##{row['Numero']}: #{hike.errors.full_messages.join(', ')}"
        end
    end

    def convert_num(value)
        return nil if value.nil? || value.to_s.strip.empty?

        # First attempt: direct integer conversion
        begin
            return value.to_i
        rescue ArgumentError, TypeError
            # Continue if direct conversion fails
        end

        # Second attempt: extract only digits
        digits_only = value.to_s.gsub(/[^\d]/, '')

        # Check if we have digits after cleaning
        return digits_only.to_i if digits_only.present?

        # Last resort
        nil
    end
end
