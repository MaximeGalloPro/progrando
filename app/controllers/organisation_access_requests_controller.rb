# frozen_string_literal: true

# Manages organization access requests, including approval, rejection, and
# cancellation of pending requests. Handles the workflow for users requesting
# access to organizations and administrators processing these requests.
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
        process_approval
        redirect_to organisation_access_requests_path, notice: t('.success')
    end

    def reject
        process_rejection
        redirect_to organisation_access_requests_path, notice: t('.success')
    end

    def destroy
        if @request&.destroy
            redirect_to organisations_path, notice: t('.success')
        else
            redirect_to organisations_path, alert: t('.error')
        end
    end

    private

    def set_request
        @request = OrganisationAccessRequest.find_by(id: params[:id])
    end

    def process_approval
        ActiveRecord::Base.transaction do
            update_request_status('approved')
            create_user_organisation
        end
    end

    def process_rejection
        update_request_status('rejected')
    end

    def update_request_status(status)
        @request.update(
            status: status,
            processed_by_id: current_user.id,
            processed_at: Time.current
        )
    end

    def create_user_organisation
        UserOrganisation.create!(
            user: @request.user,
            organisation: @request.organisation,
            profile_id: params[:organisation_access_request][:profile_id]
        )
    end
end
