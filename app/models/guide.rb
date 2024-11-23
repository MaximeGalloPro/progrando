class Guide < ApplicationRecord
    has_many :hike_histories
    has_many :hikes, through: :hike_histories
end
