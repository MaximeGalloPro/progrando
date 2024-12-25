class Organization < ApplicationRecord
    include OrganizationScoped

    validates :subdomain, presence: true, uniqueness: true
    validates :name, presence: true

    has_many :users
    has_many :events
    has_many :hike_paths
    has_many :hike_histories
end