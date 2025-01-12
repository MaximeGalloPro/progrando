class OrganisationAccessRequest < ApplicationRecord
    belongs_to :user
    belongs_to :organisation

    validates :message, presence: true
    validates :role, presence: true, inclusion: { in: %w[member guide admin] }
    validates :status, presence: true, inclusion: { in: %w[pending approved rejected] }

    before_validation :set_default_status, on: :create

    private

    def set_default_status
        self.status ||= 'pending'
    end
end