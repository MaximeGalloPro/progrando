class HikePath < ApplicationRecord
    acts_as_tenant(:organization)

    belongs_to :hike
end