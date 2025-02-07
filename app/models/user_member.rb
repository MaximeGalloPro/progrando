# frozen_string_literal: true

# Associates a User account with a Member profile,
# allowing authentication credentials to be linked with member information
class UserMember < ApplicationRecord
    belongs_to :user
    belongs_to :member
end
