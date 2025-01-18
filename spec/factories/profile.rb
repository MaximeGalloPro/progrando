# spec/factories/profiles.rb
FactoryBot.define do
    factory :profile do
        name { "Member" }
        description { 'Peut voir et s\'inscrire aux randonnées' }
        active { true }
        organisation

        # Différents types de profils
        trait :creator do
            name { "Createur" }
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
            name { "Admin" }
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
            name { "Membre" }

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