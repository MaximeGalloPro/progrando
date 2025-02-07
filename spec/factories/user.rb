# spec/factories/users.rb
FactoryBot.define do
    factory :user do
        sequence(:email) { |n| "user#{n}@exemple.com" }
        password { 'password123' }
        password_confirmation { 'password123' }

        trait :with_organisation do
            after(:create) do |user|
                create(:user_organisation, user: user)
            end
        end

        factory :admin do
            sequence(:email) { |n| "admin#{n}@exemple.com" }
            password { 'password123' }
            password_confirmation { 'password123' }
            super_admin { true }
        end

        factory :guide do
            sequence(:email) { |n| "guide#{n}@exemple.com" }
            password { 'password123' }
            password_confirmation { 'password123' }
        end
    end
end