class Organisation < ApplicationRecord
    has_many :rights, dependent: :destroy
    has_many :profiles, dependent: :destroy
    has_many :user_organisations
    has_many :users, through: :user_organisations

    validates :name, presence: true, uniqueness: true
end