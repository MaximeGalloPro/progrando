# app/controllers/stats_controller.rb
class StatsController < ApplicationController
    def dashboard
        @stats = {
            # Statistiques pour les cartes
            total_hikes: fetch_total_hikes,
            total_distance: fetch_total_distance,
            total_elevation: fetch_total_elevation,
            active_guides: fetch_active_guides,

            # Données pour les graphiques
            monthly_stats: fetch_monthly_stats,
            guide_stats: fetch_guide_stats,
        }
        @last_hikes = fetch_last_hikes
    end

    private
    def fetch_last_hikes
        Hike.with_latest_history
            .where('last_history.hiking_date < ?', Date.current)  # Utilise < au lieu de <=
            .order('last_history.hiking_date DESC')
            .limit(10)
    end


    def fetch_total_hikes
        Hike.joins(<<~SQL)
      LEFT JOIN (
        SELECT hh.*
        FROM hike_histories hh
        INNER JOIN (
          SELECT hike_number, MAX(hiking_date) as latest_date
          FROM hike_histories
          GROUP BY hike_number
        ) latest ON hh.hike_number = latest.hike_number
        AND hh.hiking_date = latest.latest_date
      ) last_history ON hikes.number = last_history.hike_number
    SQL
            .where('last_history.hiking_date >= ?', Date.current.beginning_of_year)
            .distinct
            .count
    end

    def fetch_total_distance
        Hike.joins(<<~SQL)
      LEFT JOIN (
        SELECT hh.*
        FROM hike_histories hh
        INNER JOIN (
          SELECT hike_number, MAX(hiking_date) as latest_date
          FROM hike_histories
          GROUP BY hike_number
        ) latest ON hh.hike_number = latest.hike_number
        AND hh.hiking_date = latest.latest_date
      ) last_history ON hikes.number = last_history.hike_number
    SQL
            .sum('hikes.distance_km')
    end

    def fetch_total_elevation
        Hike.joins(<<~SQL)
      LEFT JOIN (
        SELECT hh.*
        FROM hike_histories hh
        INNER JOIN (
          SELECT hike_number, MAX(hiking_date) as latest_date
          FROM hike_histories
          GROUP BY hike_number
        ) latest ON hh.hike_number = latest.hike_number
        AND hh.hiking_date = latest.latest_date
      ) last_history ON hikes.number = last_history.hike_number
    SQL
            .sum('hikes.elevation_gain')
    end

    def fetch_active_guides
        Hike.joins(<<~SQL)
      LEFT JOIN (
        SELECT hh.*
        FROM hike_histories hh
        INNER JOIN (
          SELECT hike_number, MAX(hiking_date) as latest_date
          FROM hike_histories
          GROUP BY hike_number
        ) latest ON hh.hike_number = latest.hike_number
        AND hh.hiking_date = latest.latest_date
      ) last_history ON hikes.number = last_history.hike_number
    SQL
            .where('last_history.hiking_date >= ?', Date.current.beginning_of_month)
            .distinct
            .count
    end

    def fetch_monthly_stats
        stats = Hike.joins(<<~SQL)
      LEFT JOIN (
        SELECT hh.*
        FROM hike_histories hh
        INNER JOIN (
          SELECT hike_number, MAX(hiking_date) as latest_date
          FROM hike_histories
          GROUP BY hike_number
        ) latest ON hh.hike_number = latest.hike_number
        AND hh.hiking_date = latest.latest_date
      ) last_history ON hikes.number = last_history.hike_number
    SQL
                    .where('last_history.hiking_date >= ?', 1.year.ago)
                    .group("DATE_FORMAT(last_history.hiking_date, '%Y-%m')")
                    .distinct
                    .count

        # Transformer les clés en noms de mois courts
        formatted_stats = stats.transform_keys { |k| Date.parse(k + '-01').strftime('%b') }

        # Assurer l'ordre des 12 derniers mois
        last_12_months = 12.times.map { |i| i.months.ago.strftime('%b') }.reverse

        last_12_months.each_with_object({}) { |month, hash|
            hash[month] = formatted_stats[month] || 0
        }
    end

    def fetch_guide_stats
        HikeHistory.joins(:guide)
                   .where('hiking_date >= ?', 1.year.ago)
                   .where.not(guides: { name: nil })
                   .group('guides.name')
                   .order('count_all DESC')
                   .limit(10)
                   .count
    end

    def fetch_recent_hikes
        Hike.select('hikes.trail_name, hikes.distance_km, hikes.elevation_gain, hh.hiking_date')
            .joins(<<~SQL)
      INNER JOIN hike_histories hh ON hikes.number = hh.hike_number
    SQL
            .order('hh.hiking_date DESC')
            .limit(10)
    end
end