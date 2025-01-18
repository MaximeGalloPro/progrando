# spec/factories/user_organisations.rb
FactoryBot.define do
    factory :user_organisation do
        user
        organisation
        profile
        creator { false }
    end
end