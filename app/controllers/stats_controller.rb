# frozen_string_literal: true

# Controller handling statistical data visualization and analysis for the
# organization's hiking activities. Provides aggregated metrics including total
# hikes, distances, elevations, and guide performance statistics.
class StatsController < ApplicationController
    def dashboard
        @stats = {
            total_hikes: fetch_total_hikes,
            total_distance: fetch_total_distance,
            total_elevation: fetch_total_elevation,
            active_guides: fetch_active_guides,
            monthly_stats: fetch_monthly_stats,
            guide_stats: fetch_guide_stats
        }
        @last_hikes = fetch_last_hikes
    end

    private

    def fetch_last_hikes
        Hike.for_organisation
            .joins(:latest_history)
            .select('hikes.*, hike_histories.hiking_date, members.name as member_name')
            .joins('LEFT JOIN members ON members.id = hike_histories.member_id')
            .where(hike_histories: { hiking_date: ...Date.current })
            .order('hike_histories.hiking_date DESC')
            .limit(10)
    end

    def fetch_total_hikes
        Hike.for_organisation
            .joins(:latest_history)
            .where(hike_histories: { hiking_date: Date.current.beginning_of_year.. })
            .distinct
            .count
    end

    def fetch_total_distance
        HikeHistory.for_organisation
                   .joins(:hike)
                   .sum('hikes.distance_km')
    end

    def fetch_total_elevation
        HikeHistory.for_organisation
                   .joins(:hike)
                   .sum('hikes.elevation_gain')
    end

    def fetch_active_guides
        Hike.for_organisation
            .joins(:latest_history)
            .where(hike_histories: { hiking_date: Date.current.beginning_of_month.. })
            .distinct
            .count
    end

    def fetch_monthly_stats
        stats = fetch_raw_monthly_stats
        formatted_stats = format_monthly_stats(stats)
        generate_complete_monthly_stats(formatted_stats)
    end

    def fetch_raw_monthly_stats
        Hike.for_organisation
            .joins(:latest_history)
            .where(hike_histories: { hiking_date: 1.year.ago.. })
            .group("DATE_FORMAT(hike_histories.hiking_date, '%Y-%m')")
            .distinct
            .count
    end

    def format_monthly_stats(stats)
        stats.transform_keys do |key|
            Date.parse("#{key}-01").strftime('%b')
        end
    end

    def generate_complete_monthly_stats(formatted_stats)
        last_12_months.index_with do |month|
            formatted_stats[month] || 0
        end
    end

    def last_12_months
        Array.new(12) { |i| i.months.ago.strftime('%b') }.reverse
    end

    def fetch_guide_stats
        HikeHistory.for_organisation
                   .joins(:member)
                   .where(hiking_date: 1.year.ago..)
                   .where.not(members: { name: nil })
                   .group('members.name')
                   .order('count_all DESC')
                   .limit(10)
                   .count
    end
end
