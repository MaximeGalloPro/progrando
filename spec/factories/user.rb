# spec/factories/users.rb
FactoryBot.define do
    factory :user do
        email { 'test@exemple.com' }
        password { 'password123' }
        password_confirmation { 'password123' }

        trait :with_organisation do
            after(:create) do |user|
                create(:user_organisation, user: user)
            end
        end

        factory :admin do
            email { 'admin@exemple.com' }
            super_admin { true }
        end

        factory :guide do
            email { 'guide@exemple.com' }
        end
    end
end