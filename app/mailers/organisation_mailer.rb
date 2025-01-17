# frozen_string_literal: true

# Handles organization-related email notifications, such as access requests
# from users wanting to join an organization
class OrganisationMailer < ApplicationMailer
    def access_request_notification(access_request)
        @access_request = access_request
        @user = access_request.user
        @organisation = access_request.organisation

        # Find users with rights to handle access requests
        profile_right = ProfileRight.where(
            resource: 'ProfileRight',
            action: 'toggle_authorization',
            authorized: true
        )
        profile_ids = profile_right.pluck(:profile_id)
        user_ids = UserOrganisation.where(
            organisation_id: @organisation.id,
            profile_id: profile_ids
        ).pluck(:user_id)
        users = User.where(id: user_ids)

        mail(
            to: users.pluck(:email),
            subject: "Nouvelle demande d'accès à #{@organisation.name}"
        )
    end
end
