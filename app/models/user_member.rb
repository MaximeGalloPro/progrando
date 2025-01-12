class UserMember < ApplicationRecord
    belongs_to :user
    belongs_to :member
end