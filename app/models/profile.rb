# app/models/profile.rb
class Profile < ApplicationRecord
    has_many :profile_rights, dependent: :destroy

    validates :name, presence: true, uniqueness: true

    def authorized_for?(resource, action)
        profile_rights.find_by(resource: resource.to_s, action: action.to_s)&.authorized || false
    end
end