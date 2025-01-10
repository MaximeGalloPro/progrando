class RolesController < ApplicationController

    def index
        @roles = Role.for_organisation.all
    end

    def create
        @role = Role.new(role_params)
        if @role.save
            redirect_to roles_path, notice: 'Role ajouté avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def new
        @role = Role.new
    end

    def edit
        @role = Role.for_organisation.find_by(id: params[:id])
    end

    def update
        @role = Role.for_organisation.find_by(id: params[:id])
        if @role.update(role_params)
            redirect_to roles_path, notice: 'Role modifié avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @role = Role.for_organisation.find_by(id: params[:id])
        @role.destroy
        redirect_to roles_path, notice: 'Role supprimé avec succès.'
    end

    private

    def role_params
        params.require(:role).permit(
            :name,
            :description
        )
    end

end