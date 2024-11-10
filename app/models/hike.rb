# app/models/hike.rb
class Hike < ApplicationRecord
    has_many :hike_histories, foreign_key: :hike_number, primary_key: :number

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

    before_save :generate_openrunner_url

    scope :search_by_trail_name, ->(query) {
        joins("LEFT JOIN (
      SELECT
        hike_number,
        hiking_date,
        guide_name,
        ROW_NUMBER() OVER (PARTITION BY hike_number ORDER BY hiking_date DESC) as rn
      FROM hike_histories
    ) as last_hikes ON hikes.number = last_hikes.hike_number AND last_hikes.rn = 1")
            .where("trail_name LIKE ?", "%#{query}%")
            .select("hikes.*,
            last_hikes.hiking_date as last_date,
            last_hikes.guide_name as last_guide")
    }

    private

    def generate_openrunner_url
        if openrunner_ref.present? && openrunner_ref.match?(/\A\d+\z/)
            self.openrunner_url = "https://www.openrunner.com/route-details/#{openrunner_ref}"
        end
    end
end