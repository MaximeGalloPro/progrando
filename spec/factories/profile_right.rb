# spec/factories/profile_rights.rb
FactoryBot.define do
    factory :profile_right do
        profile
        organisation { profile.organisation }
        resource { 'User' }
        action { 'index' }
        authorized { true }
    end
end