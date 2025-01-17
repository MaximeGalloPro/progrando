# frozen_string_literal: true

# Represents a set of permissions and access rights within an organisation
class Profile < ApplicationRecord
    belongs_to :organisation
    has_many :profile_rights, dependent: :destroy

    validates :name, presence: true, uniqueness: { scope: :organisation_id }
    def authorized_for?(resource, action)
        profile_rights.find_by(resource: resource.to_s, action: action.to_s)&.authorized || false
    end
end
