# app/controllers/organisation_access_requests_controller.rb
class OrganisationAccessRequestsController < ApplicationController
    before_action :set_request, only: [:approve, :reject]

    def index
        @access_requests = OrganisationAccessRequest.where(status: 'pending')
    end

    def approve
        @request.update(
            status: 'approved',
            processed_by_id: current_user.id,
            processed_at: Time.current
        )
        byebug
        UserOrganisation.create!(user: @request.user,
                                 organisation: @request.organisation,
                                 profile: @request.role)
        # Ici, vous pourriez ajouter la logique pour créer l'adhésion à l'organisation
        redirect_to organisation_access_requests_path, notice: 'Demande approuvée'
    end

    def reject
        @request.update(
            status: 'rejected',
            processed_by_id: current_user.id,
            processed_at: Time.current
        )
        redirect_to organisation_access_requests_path, notice: 'Demande rejetée'
    end

    private

    def set_request
        @request = OrganisationAccessRequest.find(params[:id])
    end
end