class Organisation < ApplicationRecord
    has_many :rights, dependent: :destroy
    has_many :profiles, dependent: :destroy
end