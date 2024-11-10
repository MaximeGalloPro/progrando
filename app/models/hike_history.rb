class HikeHistory < ApplicationRecord
    belongs_to :hike, foreign_key: :hike_number, primary_key: :number, optional: true

    # Validations de présence pour tous les champs requis
    validates :hiking_date, presence: true
    validates :hike_number, presence: true
    validates :guide_name, presence: true
    validates :guide_phone, presence: true
    validates :departure_time, presence: true

    # Validations numériques avec contraintes spécifiques
    validates :difficulty,
              numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 },
              allow_blank: true
    validates :distance_km,
              numericality: { greater_than: 0, message: "doit être supérieur à 0" },
              allow_blank: true
    validates :elevation_gain,
              numericality: { only_integer: true, greater_than_or_equal_to: 0,
                              message: "doit être un nombre entier positif" },
              allow_blank: true
    validates :carpooling_cost,
              numericality: { greater_than_or_equal_to: 0, message: "doit être un nombre positif" },
              allow_blank: true
    validates :openrunner_ref,
              numericality: { only_integer: true, message: "doit être un nombre entier" },
              allow_blank: true

    # Validation d'unicité
    validates :hiking_date, uniqueness: { scope: :hike_number,
                                          message: "Une randonnée est déjà programmée à cette date" }

    before_save :generate_openrunner_url

    private

    def generate_openrunner_url
        if openrunner_ref.present? && openrunner_ref.match?(/\A\d+\z/)
            self.openrunner_url = "https://www.openrunner.com/route-details/#{openrunner_ref}"
        end
    end
end