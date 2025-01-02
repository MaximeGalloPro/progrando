class OrganisationsController < ApplicationController
    before_action :set_organisation, only: [:show, :edit, :update, :destroy]
    before_action :check_organisation_access, only: [:show, :edit, :update, :destroy]

    def index
        @organisations = current_user.super_admin ? Organisation.all : Organisation.where(id: current_user.organisation_id)
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

    def set_organisation
        @organisation = Organisation.find(params[:id])
    end

    def check_organisation_access
        return if current_user.super_admin
        return if @organisation.id == current_user.organisation_id

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