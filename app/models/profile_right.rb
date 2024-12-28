# app/models/profile_right.rb
class ProfileRight < ApplicationRecord
    belongs_to :organisation
    belongs_to :profile

    validates :resource, presence: true
    validates :action, presence: true
    validates :profile_id, uniqueness: { scope: [:resource, :action] }

    VALID_ACTIONS = %w[index show create update destroy edit new].freeze

    validates :action, inclusion: { in: VALID_ACTIONS }
end