# frozen_string_literal: true

# Represents an organization in the system, managing its users, profiles,
# and associated rights with a unique identifying name
class Organisation < ApplicationRecord
    has_many :rights, dependent: :destroy
    has_many :profiles, dependent: :destroy
    has_many :user_organisations, dependent: :destroy
    has_many :users, through: :user_organisations

    validates :name, presence: true, uniqueness: true
end
