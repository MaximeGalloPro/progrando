class OrganisationsController < ApplicationController
    before_action :set_organisation, only: [:show, :edit, :update, :destroy]
    before_action :check_organisation_access, only: [:edit, :update, :destroy]

    def request_access
        @organisation = Organisation.find_by(id: params[:id])
        @member = current_user&.members&.for_organisation&.first || Member.new
        if request.post?
            check_already_requested = OrganisationAccessRequest.where(user: current_user, organisation: @organisation).exists?
            return redirect_to organisations_path, alert: 'Vous avez déjà envoyé une demande pour cette organisation' if check_already_requested
            handle_member
            access_request = OrganisationAccessRequest.new(
                user: current_user,
                organisation: @organisation,
                message: params[:message],
                role: params[:role],
            )

            if access_request.save
                OrganisationMailer.access_request_notification(access_request).deliver_later
                redirect_to organisations_path, notice: 'Votre demande a été envoyée avec succès'
            else
                flash.now[:error] = 'Erreur lors de l\'envoi de la demande'
                render :request_access
            end
        end
    end

    def index
        @organisations = Organisation.all
        @access_requests = OrganisationAccessRequest.where(user_id: current_user.id)
    end

    def switch
        @organisations = current_user.super_admin ? Organisation.all : Organisation.where(id: current_user.organisations.pluck(:id))

        if params[:id]
            @organisation = Organisation.find(params[:id])
            if current_user.super_admin || current_user.organisations.include?(@organisation)
                current_user.update(current_organisation_id: @organisation.id)
                redirect_to authenticated_root_path, notice: "Vous utilisez maintenant l'organisation #{@organisation.name}"
            else
                redirect_to organisations_path, alert: "Vous n'avez pas accès à cette organisation"
            end
        end
    end

    def show
    end

    def new
        @organisation = Organisation.new
    end

    def edit
    end

    def create
        @organisation = Organisation.new(organisation_params)
        if @organisation.save
            profile = Profile.find_or_create_by(name: 'Createur', organisation_id: @organisation.id)
            UserOrganisation.create(user: current_user,
                                    organisation: @organisation,
                                    profile: profile,
                                    creator: true)
            redirect_to @organisation, notice: 'Organisation créée avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def update
        if @organisation.update(organisation_params)
            redirect_to @organisation, notice: 'Organisation mise à jour avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @organisation.destroy
        redirect_to organisations_url, notice: 'Organisation supprimée avec succès.'
    end

    private

    def handle_member
        if !@member.persisted?
            @member.update(name: params[:name], email: params[:email],
                           phone: params[:phone], organisation: @organisation)
        else
            @member = Member.create(name: params[:name], email: params[:email],
                                    phone: params[:phone], organisation: @organisation)
            UserMember.create(user: current_user, member: @member)
        end
    end

    def set_organisation
        @organisation = Organisation.find(params[:id])
    end

    def check_organisation_access
        return if current_user.super_admin
        return if @organisation.id == current_user.user_organisations.for_organisation&.first&.organisation_id

        flash[:error] = "Vous n'avez pas accès à cette organisation"
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