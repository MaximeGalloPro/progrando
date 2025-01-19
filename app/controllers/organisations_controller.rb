# frozen_string_literal: true

# Controller managing organization-related operations including creation, updates,
# access requests, and organization switching. Handles user permissions and member
# associations within organizations.
class OrganisationsController < ApplicationController
    before_action :set_organisation, only: %i[show edit update destroy]
    before_action :check_organisation_access, only: %i[edit update destroy]

    def request_access
        load_organisation_and_member
        return unless request.post?
        return handle_existing_request if existing_request?

        create_or_update_member
        submit_access_request
    end

    def index
        @organisations = Organisation.all
        @access_requests = OrganisationAccessRequest.where(user_id: current_user.id)
    end

    def switch
        load_available_organisations
        return unless params[:id]

        attempt_organisation_switch
    end

    def show; end

    def new
        @organisation = Organisation.new
    end

    def edit; end

    def create
        @organisation = Organisation.new(organisation_params)

        if @organisation.save
            setup_creator_profile
            redirect_to @organisation, notice: t('.success')
        else
            render :new, status: :unprocessable_entity
        end
    end

    def update
        if @organisation.update(organisation_params)
            redirect_to @organisation, notice: t('.success')
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @organisation.destroy
        redirect_to organisations_url, notice: t('.success')
    end

    private

    def load_organisation_and_member
        @organisation = Organisation.find_by(id: params[:id])
        @member = find_or_initialize_member
    end

    def find_or_initialize_member
        current_user.then do |user|
            user.members.then do |members|
                members.for_organisation.first
            end
        end || Member.new
    end

    def existing_request?
        OrganisationAccessRequest.exists?(
            user: current_user,
            organisation: @organisation
        )
    end

    def handle_existing_request
        redirect_to organisations_path, alert: t('.already_requested')
    end

    def create_or_update_member
        if @member.new_record?
            create_new_member
        else
            update_existing_member
        end
    end

    def create_new_member
        @member = Member.create(member_params.merge(organisation: @organisation))
        UserMember.create(user: current_user, member: @member)
    end

    def update_existing_member
        @member.update(member_params.merge(organisation: @organisation))
    end

    def member_params
        {
            name: params[:name],
            email: params[:email],
            phone: params[:phone]
        }
    end

    def submit_access_request
        access_request = build_access_request

        if access_request.save
            handle_successful_request(access_request)
        else
            handle_failed_request
        end
    end

    def build_access_request
        OrganisationAccessRequest.new(
            user: current_user,
            organisation: @organisation,
            message: params[:message],
            role: params[:role]
        )
    end

    def handle_successful_request(access_request)
        OrganisationMailer.access_request_notification(access_request).deliver_later
        redirect_to organisations_path, notice: t('.success')
    end

    def handle_failed_request
        flash.now[:error] = t('.error')
        render :request_access
    end

    def load_available_organisations
        @organisations = if current_user.super_admin
                             Organisation.all
                         else
                             Organisation.where(id: current_user.organisations.pluck(:id))
                         end
    end

    def attempt_organisation_switch
        @organisation = Organisation.find(params[:id])

        if can_switch_to_organisation?
            perform_organisation_switch
        else
            deny_organisation_switch
        end
    end

    def can_switch_to_organisation?
        current_user.super_admin || current_user.organisations.include?(@organisation)
    end

    def perform_organisation_switch
        current_user.update(current_organisation_id: @organisation.id)
        redirect_to authenticated_root_path, notice: t('.success', name: @organisation.name)
    end

    def deny_organisation_switch
        redirect_to organisations_path, alert: t('.access_denied')
    end

    def setup_creator_profile
        profile = Profile.find_or_create_by(
            name: 'Createur',
            organisation_id: @organisation.id
        )

        UserOrganisation.create(
            user: current_user,
            organisation: @organisation,
            profile: profile,
            creator: true
        )
    end

    def set_organisation
        @organisation = Organisation.find_by(id: params[:id])
    end

    def check_organisation_access
        return if current_user.super_admin

        organisation_id = current_user.user_organisations.for_organisation&.first&.organisation_id
        return if @organisation&.id == organisation_id

        flash[:error] = t('.access_denied')
        redirect_to organisations_path
    end

    def organisation_params
        params.require(:organisation).permit(
            :name, :slug, :url, :logo_url, :description, :location,
            :email, :phone, :contact_name, :contact_email, :contact_phone,
            :contact_position, :contact_language
        )
    end
end
