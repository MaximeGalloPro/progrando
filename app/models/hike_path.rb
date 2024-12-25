class HikePath < ApplicationRecord
    include OrganizationScoped

    belongs_to :hike
end