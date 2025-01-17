# frozen_string_literal: true

# Manages members within an organization, including creation, updates, and deletion.
# Handles the assignment of roles to members and maintains member information.
class MembersController < ApplicationController
    before_action :set_roles
    before_action :set_member, only: %i[edit update destroy]

    def index
        @members = Member.for_organisation.includes(:role)
    end

    def new
        @member = Member.new
    end

    def edit; end

    def create
        @member = Member.new(member_params)

        if @member.save
            redirect_to members_path, notice: t('.success')
        else
            render :new, status: :unprocessable_entity
        end
    end

    def update
        if @member.update(member_params)
            redirect_to members_path, notice: t('.success')
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @member.destroy
        redirect_to members_path, notice: t('.success')
    end

    private

    def set_roles
        @roles = Role.for_organisation.all
    end

    def set_member
        @member = Member.for_organisation.find_by(id: params[:id])
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
