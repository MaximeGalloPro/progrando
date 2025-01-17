# frozen_string_literal: true

# lib/tasks/hike_histories.rake
require 'csv'
require 'date'

namespace :hike_histories do
    desc 'Import hike histories from CSV file'
    task import: :environment do
        HikeHistoriesImporter.new.import
    end
end

# lib/services/hike_histories_importer.rb
class HikeHistoriesImporter
    def initialize
        @log_file = Rails.root.join('log/hike_histories_import.log')
        @csv_file = Rails.root.join('lib/data/progrando_progs.csv')
        @date_parser = DateParser.new
        @number_converter = NumberConverter.new
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
        hiking_date = @date_parser.parse(row['Dates'])
        unless hiking_date
            log.puts "Skipping row: Invalid date format in Dates column: #{row['Dates']}"
            return
        end

        member = create_or_update_member(row)
        history = create_or_update_history(row, hiking_date, member)
        log_result(history, row, log)
    rescue StandardError => e
        log.puts "Error processing row: #{e.message}"
    end

    def create_or_update_member(row)
        member = Member.find_or_initialize_by(phone: row['Tel.']&.strip)
        member.assign_attributes(name: row['Animateur']&.strip)
        member.save(validate: false)
        member
    end

    def create_or_update_history(row, hiking_date, member)
        history = find_or_initialize_history(row, hiking_date)
        history.assign_attributes(history_attributes(row, member))
        history.save(validate: false)
        history
    end

    def find_or_initialize_history(row, hiking_date)
        HikeHistory.find_or_initialize_by(
            hiking_date: hiking_date,
            openrunner_ref: @number_converter.convert(row['Ref']&.strip)
        )
    end

    def history_attributes(row, member)
        {
            departure_time: row['Depart']&.strip,
            day_type: row['Journee']&.strip,
            carpooling_cost: @number_converter.convert(row['* C.V.']),
            member_id: member&.id,
            hike_id: find_hike_id(row)
        }
    end

    def find_hike_id(row)
        hike_id = Hike.find_by(number: @number_converter.convert(row['Ref']))&.id
        hike_id || Hike.find_by(number: @number_converter.convert(row['N°']))&.id
    end

    def log_result(history, row, log)
        if history.persisted?
            success_message = "Successfully imported history for hike ##{history.hike_id} on #{history.hiking_date}"
            puts success_message
            log.puts success_message
        else
            log.puts(
                "Error importing history for hike ##{row['N°']}: " \
                "#{history.errors.full_messages.join(', ')}"
            )
        end
    end
end

# lib/services/date_parser.rb
class DateParser
    FRENCH_MONTHS = {
        'janvier' => 1,
        'fevrier' => 2,
        'février' => 2,
        'mars' => 3,
        'avril' => 4,
        'mai' => 5,
        'juin' => 6,
        'juillet' => 7,
        'aout' => 8,
        'août' => 8,
        'septembre' => 9,
        'octobre' => 10,
        'novembre' => 11,
        'decembre' => 12,
        'décembre' => 12
    }.freeze

    def parse(date_value)
        return nil if date_value.blank?
        return date_value if date_value.is_a?(Date)

        parse_french_date(date_value) || parse_default_date(date_value)
    rescue ArgumentError, TypeError => e
        puts "Error parsing date '#{date_value}': #{e.message}"
        nil
    end

    private

    def parse_french_date(date_value)
        match = date_value.match(/([[:alpha:]]+),\s+([[:alpha:]]+)\s+(\d{2}),\s+(\d{4})/)
        return nil unless match

        month_name = normalize_string(match[2])
        day = match[3].to_i
        year = match[4].to_i
        month = FRENCH_MONTHS[month_name]

        create_date(year, month, day) if month
    end

    def create_date(year, month, day)
        Date.new(year, month, day)
    rescue ArgumentError => e
        puts "Error creating date object: #{e.message}"
        nil
    end

    def parse_default_date(date_value)
        Date.parse(date_value.to_s)
    end

    def normalize_string(str)
        str = str.to_s.downcase
        ACCENTS_MAP.each do |accent, sans_accent|
            str = str.gsub(accent, sans_accent)
        end
        str
    end

    ACCENTS_MAP = {
        'é' => 'e', 'è' => 'e', 'ê' => 'e',
        'à' => 'a', 'â' => 'a',
        'ï' => 'i', 'î' => 'i',
        'û' => 'u', 'ù' => 'u',
        'ô' => 'o',
        'ç' => 'c'
    }.freeze
end

# lib/services/number_converter.rb
class NumberConverter
    def convert(value)
        return nil if value.nil? || value.to_s.strip.empty?

        convert_to_integer(value) || extract_digits(value)
    end

    private

    def convert_to_integer(value)
        value.to_i
    rescue ArgumentError, TypeError
        nil
    end

    def extract_digits(value)
        digits_only = value.to_s.gsub(/[^\d]/, '')
        digits_only.present? ? digits_only.to_i : nil
    end
end
