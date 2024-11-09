class Hike < ApplicationRecord
    # Validations
    validates :number, presence: true, uniqueness: true, numericality: { only_integer: true }
    validates :day, presence: true, numericality: { only_integer: true }
    validates :difficulty, numericality: { only_integer: true }, allow_nil: true
    validates :carpooling_cost, numericality: { only_integer: true }, allow_nil: true
    validates :distance_km, numericality: true, allow_nil: true
    validates :elevation_gain, numericality: { only_integer: true }, allow_nil: true
    validates :last_schedule, presence: true

    # Callback to generate openrunner_url before save
    before_save :generate_openrunner_url

    private

    def generate_openrunner_url
        if openrunner_ref.present? && openrunner_ref.match?(/\A\d+\z/)
            self.openrunner_url = "https://www.openrunner.com/route-details/#{openrunner_ref}"
        end
    end
end