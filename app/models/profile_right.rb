# frozen_string_literal: true

# app/models/profile_right.rb
class ProfileRight < ApplicationRecord
    belongs_to :organisation
    belongs_to :profile

    validates :resource, presence: true
    validates :action, presence: true
    validates :profile_id, uniqueness: { scope: %i[resource action] }
end
