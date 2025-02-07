# frozen_string_literal: true

# Represents a member in the system with optional organisation affiliation
# and role assignment, tracking their hike participation history
class Member < ApplicationRecord
    belongs_to :organisation, optional: true
    has_many :hike_histories, dependent: :destroy
    has_many :hikes, through: :hike_histories
    validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
    belongs_to :role, optional: true
end
