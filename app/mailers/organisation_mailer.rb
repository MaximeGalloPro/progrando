class OrganisationMailer < ApplicationMailer
    def access_request_notification(access_request)
        @access_request = access_request
        @user = access_request.user
        @organisation = access_request.organisation
        profile_right = ProfileRight.where(resource: 'ProfileRight', action: 'toggle_authorization', authorized: true)
        profile_ids = profile_right.pluck(:profile_id)
        user_ids = UserOrganisation.where(organisation_id: @organisation.id, profile_id: profile_ids).pluck(:user_id)
        users = User.where(id: user_ids)
        mail(
            to: users.pluck(:email),
            subject: "Nouvelle demande d'accès à #{@organisation.name}"
        )
    end
end