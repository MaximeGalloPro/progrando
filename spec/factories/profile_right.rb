# spec/factories/profile_right.rb
FactoryBot.define do
    factory :profile_right do
        profile
        organisation { profile.organisation }
        sequence(:resource) { |n| "Resource#{n}" }
        sequence(:action) { |n| "action#{n}" }
        authorized { true }
    end
end