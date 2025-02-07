# app/models/profile_right.rb
class ProfileRight < ApplicationRecord
    belongs_to :organisation
    belongs_to :profile

    validates :resource, presence: true
    validates :action, presence: true
    validates :profile_id, uniqueness: { scope: %i[resource action] }
    validate :cannot_modify_own_profile_rights, on: :update

    private

    def cannot_modify_own_profile_rights
        if Current.user&.user_organisations&.for_organisation&.first&.profile&.id == profile_id
            errors.add(:base, I18n.t('profiles.toggle_authorization.cannot_modify_own_profile'))
        end
    end
end