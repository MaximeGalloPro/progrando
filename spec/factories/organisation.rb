# spec/factories/organisations.rb
FactoryBot.define do
    factory :organisation do
        sequence(:name) { |n| "Organisation#{n}" }
        sequence(:slug) { |n| "org-#{n}" }
        sequence(:email) { |n| "contact#{n}@example.com" }
        url { "http://www.example.com" }
        description { "Une super organisation" }
        location { "Paris" }
        phone { "0123456789" }

        # Champs contact
        contact_name { "John Doe" }
        contact_email { "john@example.com" }
        contact_phone { "0123456789" }
        contact_position { "Président" }
        contact_language { "Français" }
    end
end