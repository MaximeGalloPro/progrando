class UserOrganisation < ApplicationRecord
    belongs_to :user
    belongs_to :organisation
    belongs_to :profile
end 