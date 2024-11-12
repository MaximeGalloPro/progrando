# app/controllers/stats_controller.rb
class StatsController < ApplicationController
    def dashboard
        @stats = {
            # Statistiques générales
            total_hikes: calculate_total_hikes,
            total_distance: calculate_total_distance,
            total_elevation: calculate_total_elevation,
            active_guides: calculate_active_guides,

            # Données pour les graphiques
            monthly_stats: calculate_monthly_stats,
            guide_stats: calculate_guide_stats,

            # Dernières randonnées
            recent_hikes: fetch_recent_hikes
        }
    end

    private

    def calculate_total_hikes
        HikeHistory.where('hiking_date >= ?', Date.current.beginning_of_year).count
    end

    def calculate_total_distance
        HikeHistory.sum(:distance_km)
    end

    def calculate_total_elevation
        HikeHistory.sum(:elevation_gain)
    end

    def calculate_active_guides
        HikeHistory
            .where('hiking_date >= ?', Date.current.beginning_of_month)
            .distinct
            .count(:guide_name)
    end

    def calculate_monthly_stats
        stats = HikeHistory
                    .where('hiking_date >= ?', 1.year.ago)
                    .group("DATE_FORMAT(hiking_date, '%Y-%m')")
                    .count
                    .transform_keys { |k| Date.parse(k + '-01').strftime('%b') }

        last_12_months = 12.times.map { |i|
            i.months.ago.strftime('%b')
        }.reverse

        last_12_months.each_with_object({}) { |month, hash|
            hash[month] = stats[month] || 0
        }
    end

    def calculate_guide_stats
        HikeHistory
            .where('hiking_date >= ?', 1.year.ago)
            .group(:guide_name)
            .count
            .sort_by { |_, count| -count }
            .first(10)
            .to_h
    end

    def fetch_recent_hikes
        HikeHistory
            .order(hiking_date: :desc)
            .limit(10)
    end
end