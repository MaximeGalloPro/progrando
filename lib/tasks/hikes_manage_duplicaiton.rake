# frozen_string_literal: true

# lib/tasks/hikes_manage_duplication.rake
namespace :hikes do
    desc 'Merge duplicate hikes based on openrunner_ref and migrate their histories'
    task deduplicate: :environment do
        HikeDeduplicationService.new.deduplicate
    end

    desc 'List duplicate hikes based on openrunner_ref'
    task list_duplicates: :environment do
        HikeDeduplicationService.new.list_duplicates
    end
end

# lib/services/hike_deduplication_service.rb
class HikeDeduplicationService
    def initialize(logger: Logger.new($stdout))
        @logger = logger
        @logger.level = Logger::INFO
    end

    def deduplicate
        @logger.info 'Starting hikes deduplication process...'

        duplicate_refs = find_duplicate_refs
        @logger.info "Found #{duplicate_refs.size} openrunner references with duplicates"

        process_duplicates(duplicate_refs)
    end

    def list_duplicates
        duplicate_refs = find_duplicate_refs

        if duplicate_refs.empty?
            @logger.info 'No duplicates found'
            return
        end

        log_duplicate_groups(duplicate_refs)
    end

    private

    def find_duplicate_refs
        Hike.where.not(openrunner_ref: [nil, '', '0'])
            .group(:openrunner_ref)
            .having('COUNT(*) > 1')
            .pluck(:openrunner_ref)
    end

    def process_duplicates(duplicate_refs)
        ActiveRecord::Base.transaction do
            duplicate_refs.each { |ref| process_duplicate_group(ref) }
            log_summary(duplicate_refs)
        rescue StandardError => e
            handle_error(e)
            raise ActiveRecord::Rollback
        end
    end

    def process_duplicate_group(ref)
        duplicate_hikes = Hike.where(openrunner_ref: ref).order(:created_at)
        hike_to_keep = duplicate_hikes.first
        hikes_to_remove = duplicate_hikes[1..]

        log_group_processing(ref, hike_to_keep)
        migrate_and_remove_duplicates(hike_to_keep, hikes_to_remove)
    end

    def migrate_and_remove_duplicates(hike_to_keep, hikes_to_remove)
        hikes_to_remove.each do |hike|
            @logger.info "  - Migrating histories from hike ##{hike.id} (#{hike.trail_name})"
            migrate_histories(hike, hike_to_keep)
            remove_duplicate(hike)
        end
    end

    def migrate_histories(from_hike, to_hike)
        histories = HikeHistory.where(hike_id: from_hike.number)
        histories.each do |history|
            history.update(hike_id: to_hike.id)
        end
    end

    def remove_duplicate(hike)
        @logger.info "  - Removing duplicate hike ##{hike.id}"
        hike.destroy
    end

    def log_group_processing(ref, hike_to_keep)
        @logger.info "Processing openrunner_ref #{ref}:"
        @logger.info "  - Keeping hike ##{hike_to_keep.id} (#{hike_to_keep.trail_name})"
    end

    def log_summary(duplicate_refs)
        @logger.info 'Deduplication completed successfully'
        @logger.info "\nSummary:"
        @logger.info "- Processed #{duplicate_refs.size} duplicate groups"
        @logger.info "- Remaining hikes: #{Hike.count}"
        @logger.info "- Total histories: #{HikeHistory.count}"
    end

    def log_duplicate_groups(duplicate_refs)
        @logger.info "Found #{duplicate_refs.size} duplicate groups:"

        duplicate_refs.each do |ref|
            log_duplicate_group(ref)
        end
    end

    def log_duplicate_group(ref)
        hikes = Hike.where(openrunner_ref: ref)
        @logger.info "\nOpenrunner ref #{ref}:"

        hikes.each do |hike|
            histories_count = HikeHistory.where(hike_id: hike.id).count
            @logger.info "- #{hike.trail_name} (ID: #{hike.id}, Histories: #{histories_count})"
        end
    end

    def handle_error(error)
        @logger.error "Error during deduplication: #{error.message}"
        @logger.error error.backtrace.join("\n")
    end
end
