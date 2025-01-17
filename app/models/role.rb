# frozen_string_literal: true

# Represents a role within an organization that can be assigned to members,
# defining their position or function within that organization
class Role < ApplicationRecord
    belongs_to :organisation
end
