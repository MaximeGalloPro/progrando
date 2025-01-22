# spec/factories/profiles.rb
FactoryBot.define do
    factory :profile do
        sequence(:name) { |n| "Member-#{n}" }
        description { 'Peut voir et s\'inscrire aux randonnées' }
        active { true }
        organisation

        # Différents types de profils
        trait :creator do
            name { |n| "Createur - #{organisation.name}" }
            description { 'Créateur et a donc accès complet à toutes les fonctionnalités' }

            after(:create) do |profile|
                GlobalConfig::MODELS.each do |resource|
                    GlobalConfig::ACTION.each do |action|
                        create(:profile_right,
                               profile: profile,
                               resource: resource,
                               action: action,
                               authorized: true,
                               organisation: profile.organisation
                        )
                    end
                end
            end
        end

        trait :admin do
            name { |n| "Admin - #{organisation.name}" }
            description { 'Accès complet à toutes les fonctionnalités' }

            after(:create) do |profile|
                GlobalConfig::MODELS.each do |resource|
                    GlobalConfig::ACTION.each do |action|
                        create(:profile_right,
                               profile: profile,
                               resource: resource,
                               action: action,
                               authorized: true,
                               organisation: profile.organisation
                        )
                    end
                end

                GlobalConfig::SPECIAL_ACTIONS.each do |resource, actions|
                    actions.each do |action|
                        create(:profile_right,
                               profile: profile,
                               resource: resource,
                               action: action,
                               authorized: true,
                               organisation: profile.organisation
                        )
                    end
                end
            end
        end

        trait :member do
            name { |n| "Membre - #{organisation.name}" }

            after(:create) do |profile|
                GlobalConfig::MEMBER_RIGHTS.each do |resource, actions|
                    actions.each do |action|
                        create(:profile_right,
                               profile: profile,
                               resource: resource,
                               action: action,
                               authorized: true,
                               organisation: profile.organisation
                        )
                    end
                end

                GlobalConfig::SPECIAL_ACTIONS.each do |resource, actions|
                    actions.each do |action|
                        create(:profile_right,
                               profile: profile,
                               resource: resource,
                               action: action,
                               authorized: true,
                               organisation: profile.organisation
                        )
                    end
                end
            end
        end
    end
end