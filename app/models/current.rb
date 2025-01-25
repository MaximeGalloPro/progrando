# frozen_string_literal: true

# Handles per-request global attributes, specifically tracking
# the current organisation context throughout the request cycle
class Current < ActiveSupport::CurrentAttributes
    attribute :organisation
    attribute :user
end
