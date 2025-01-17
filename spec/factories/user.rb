# spec/factories/users.rb
FactoryBot.define do
    factory :user do
        email { 'test@exemple.com' }
        password { 'password123' }
        password_confirmation { 'password123' }

        # Si vous avez besoin de créer différents types d'utilisateurs
        factory :admin do
            email { 'admin@exemple.com' }
            # Ajoutez ici les attributs spécifiques pour un admin
        end

        factory :guide do
            email { 'guide@exemple.com' }
            # Ajoutez ici les attributs spécifiques pour un guide
        end
    end
end