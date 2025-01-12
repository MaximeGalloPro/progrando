class OrganisationMailer < ApplicationMailer
    def access_request_notification(access_request)
        @access_request = access_request
        @user = access_request.user
        @organisation = access_request.organisation

        mail(
            to: @organisation.admins.pluck(:email),
            subject: "Nouvelle demande d'accès à #{@organisation.name}"
        )
    end
end