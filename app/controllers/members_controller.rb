# frozen_string_literal: true

class MembersController < ApplicationController
    before_action :get_roles

    def index
        @members = Member.for_organisation.includes(:role)
    end

    def new
        @member = Member.new
    end

    def edit
        @member = Member.for_organisation.find_by(id: params[:id])
    end

    def create
        @member = Member.new(member_params)
        if @member.save
            redirect_to members_path, notice: 'Membe ajouté avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def update
        @member = Member.for_organisation.find_by(id: params[:id])
        if @member.update(member_params)
            redirect_to members_path, notice: 'Membre modifié avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @member = Member.for_organisation.find_by(id: params[:id])
        @member.destroy
        redirect_to members_path, notice: 'Membre supprimé avec succès.'
    end

    private

    def get_roles
        @roles = Role.for_organisation.all
    end

    def member_params
        params.require(:member).permit(
            :name,
            :phone,
            :email,
            :role_id
        )
    end
end
