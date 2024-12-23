# app/models/profile_right.rb
class ProfileRight < ApplicationRecord
    acts_as_tenant(:organization)

    belongs_to :profile

    validates :resource, presence: true
    validates :action, presence: true
    validates :profile_id, uniqueness: { scope: [:resource, :action] }

    VALID_ACTIONS = %w[index show create update destroy edit].freeze

    validates :action, inclusion: { in: VALID_ACTIONS }
end