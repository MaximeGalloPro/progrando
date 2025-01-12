class ApplicationRecord < ActiveRecord::Base
    primary_abstract_class

    before_create :set_organisation_id

    scope :for_organisation, -> {
        where(organisation_id: Current.organisation.id) if Current.organisation
    }

    private

    def exclude_model
        ['User', 'Organisation', 'UserMember']
    end

    def set_organisation_id
        return if exclude_model.include?(self.class.name)
        return if self&.organisation_id&.present?
        self.organisation_id = Current.organisation&.id
    end
end