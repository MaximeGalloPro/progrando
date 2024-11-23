class Hike < ApplicationRecord
    # Associations
    has_many :hike_histories, foreign_key: :hike_number, primary_key: :number
    has_many :guides, through: :hike_histories

    # Validations
    validates :number, presence: true, uniqueness: true, numericality: { only_integer: true }
    validates :difficulty, presence: true,
              numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
    validates :starting_point, presence: true
    validates :trail_name, presence: true
    validates :carpooling_cost,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 },
              allow_blank: true
    validates :distance_km,
              numericality: { greater_than: 0 },
              allow_blank: true
    validates :elevation_gain,
              numericality: { only_integer: true, greater_than_or_equal_to: 0 },
              allow_blank: true
    validates :openrunner_ref, presence: true,
              numericality: { only_integer: true }

    # Scopes de base
    scope :ordered_by_trail_name, -> { order(:trail_name) }
    scope :by_difficulty, ->(level) { where(difficulty: level) }
    scope :recent_first, -> { order(last_schedule: :desc) }

    # Scope pour la jointure avec l'historique le plus récent
    scope :with_latest_history, -> {
        select('hikes.*, last_history.hiking_date, last_history.id as last_history_id, guides.name as guide_name')
            .joins(<<~SQL.squish)
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
                LEFT JOIN guides ON guides.id = last_history.guide_id
            SQL
    }

    scope :search_by_term, ->(term) {
        normalized_term = term.strip
        date_pattern = normalized_term.match(/(\d{1,2})\/(\d{4})/)

        if date_pattern
            month = date_pattern[1].to_i
            year = date_pattern[2].to_i
            start_date = Date.new(year, month, 1)
            end_date = start_date.end_of_month

            where("DATE(last_history.hiking_date) BETWEEN ? AND ?", start_date, end_date)
        else
            wild_term = "%#{normalized_term}%"
            where(
                "hikes.trail_name LIKE :term OR
         hikes.starting_point LIKE :term OR
         CAST(hikes.number AS CHAR) LIKE :term LIKE :term",
                term: wild_term
            )
        end
    }

    # Scope pour l'ordre par date de dernière randonnée
    scope :order_by_latest_date, -> {
        order(Arel.sql("CASE WHEN last_history.hiking_date IS NULL THEN 1 ELSE 0 END, last_history.hiking_date ASC"))
    }

    # Scope pour filtrer par période
    scope :scheduled_between, ->(start_date, end_date) {
        where(last_schedule: start_date..end_date)
    }

    # Scopes pour les statistiques
    scope :with_elevation, -> { where.not(elevation_gain: nil) }
    scope :with_distance, -> { where.not(distance_km: nil) }
    scope :by_difficulty_range, ->(min, max) { where(difficulty: min..max) }

    # Méthodes d'instance
    # def last_hike
    #     hike_histories.order(hiking_date: :desc).first
    # end

    def difficulty_text
        case difficulty
        when 1 then "Facile"
        when 2 then "Moyen"
        when 3 then "Difficile"
        when 4 then "Très difficile"
        when 5 then "Extrême"
        else "Non défini"
        end
    end

    # Méthodes de classe
    def self.total_distance
        sum(:distance_km)
    end

    def last_hiking_date
        self['hiking_date']
    end

    # app/models/hike.rb
    # Ajoutez cette méthode de classe
    def self.todays_hike
        joins(:hike_histories)
            .where('hike_histories.hiking_date = ?', Date.current)
            .select('hikes.*, hike_histories.departure_time, hike_histories.hiking_date, guides.name as guide_name')
            .joins('LEFT JOIN guides ON guides.id = hike_histories.guide_id')
            .first
    end
end