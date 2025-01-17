# frozen_string_literal: true

# Represents the association between a User and an Organisation,
# including their Profile within that organisation
class UserOrganisation < ApplicationRecord
    belongs_to :user
    belongs_to :organisation
    belongs_to :profile
end
