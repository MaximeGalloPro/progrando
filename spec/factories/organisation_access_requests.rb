# spec/factories/organisation_access_requests.rb
FactoryBot.define do
    factory :organisation_access_request do
        user
        organisation
        message { "Je souhaite rejoindre cette organisation" }
        role { "member" }
        status { "pending" }
    end
end