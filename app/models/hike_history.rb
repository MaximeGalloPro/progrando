class HikeHistory < ApplicationRecord
    belongs_to :hike, foreign_key: :openrunner_ref, primary_key: :number, optional: true
    belongs_to :guide

    # Validations de présence pour tous les champs requis
    validates :hiking_date, presence: true
    validates :hike_number, presence: true
    validates :departure_time, presence: true

    # Validations numériques avec contraintes spécifiques
    validates :carpooling_cost,
              numericality: { greater_than_or_equal_to: 0, message: "doit être un nombre positif" },
              allow_blank: true
    validates :openrunner_ref,
              numericality: { only_integer: true, message: "doit être un nombre entier" },
              allow_blank: true
    validates :hiking_date, uniqueness: { scope: :hike_number,
                                          message: "Cette randonnée est déjà programmée à cette date" }
end