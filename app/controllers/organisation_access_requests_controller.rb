# frozen_string_literal: true

# app/controllers/organisation_access_requests_controller.rb
class OrganisationAccessRequestsController < ApplicationController
    before_action :set_request, only: %i[edit update reject destroy]

    def index
        @access_requests = OrganisationAccessRequest.where(status: 'pending')
    end

    def edit
        @profiles = Profile.for_organisation.all
        render layout: false
    end

    def update
        @request.update(
            status: 'approved',
            processed_by_id: current_user.id,
            processed_at: Time.current
        )
        UserOrganisation.create!(user: @request.user,
                                 organisation: @request.organisation,
                                 profile_id: params[:organisation_access_request][:profile_id])
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

    def destroy
        if @request&.destroy
            redirect_to organisations_path, notice: 'Demande annulée'
        else
            redirect_to organisations_path, alert: 'Erreur lors du rejet de la demande'
        end
    end

    private

    def set_request
        @request = OrganisationAccessRequest.find_by(id: params[:id])
    end
end
