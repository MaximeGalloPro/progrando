class ApplicationRecord < ActiveRecord::Base
    primary_abstract_class

    before_create :set_organisation_id

    default_scope -> {
        return unless Current.organisation.present?
        return if self.table_name == 'organisations'
        where(organisation_id: Current.organisation.id)
    }

    private

    def set_organisation_id
        return if self.is_a?(Organisation)
        return if self.organisation_id.present?
        self.organisation_id = Current.organisation&.id
    end
end