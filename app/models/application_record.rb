# frozen_string_literal: true

# Base application record class that all models inherit from.
# Handles organisation-specific record management and automatic
# organisation_id assignment for multi-tenancy support
class ApplicationRecord < ActiveRecord::Base
    primary_abstract_class

    before_create :set_organisation_id

    scope :for_organisation, lambda {
        where(organisation_id: Current.organisation.id) if Current.organisation
    }

    private

    def exclude_model
        %w[User Organisation UserMember]
    end

    def set_organisation_id
        return if exclude_model.include?(self.class.name)
        return if organisation_id.present?

        self.organisation_id = Current.organisation&.id
    end
end
