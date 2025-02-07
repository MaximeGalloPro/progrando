# frozen_string_literal: true

# Controller handling the CRUD operations for Role management within an organization.
# Provides functionality to create, read, update, and delete roles, with proper
# organization scoping and JSON API support.
class RolesController < ApplicationController
    before_action :set_role, only: %i[show edit update destroy]

    # GET /roles or /roles.json
    def index
        @roles = Role.for_organisation.all
    end

    # GET /roles/1 or /roles/1.json
    def show; end

    # GET /roles/new
    def new
        @role = Role.new
    end

    # GET /roles/1/edit
    def edit; end

    # POST /roles or /roles.json
    def create
        @role = Role.new(role_params)

        respond_to do |format|
            if @role.save
                format.html { redirect_to @role, notice: t('.success') }
                format.json { render :show, status: :created, location: @role }
            else
                format.html { render :new, status: :unprocessable_entity }
                format.json { render json: @role.errors, status: :unprocessable_entity }
            end
        end
    end

    # PATCH/PUT /roles/1 or /roles/1.json
    def update
        respond_to do |format|
            if @role.update(role_params)
                format.html { redirect_to @role, notice: t('.success') }
                format.json { render :show, status: :ok, location: @role }
            else
                format.html { render :edit, status: :unprocessable_entity }
                format.json { render json: @role.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /roles/1 or /roles/1.json
    def destroy
        @role.destroy

        respond_to do |format|
            format.html { redirect_to roles_path, status: :see_other, notice: t('.success') }
            format.json { head :no_content }
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_role
        @role = Role.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def role_params
        params.require(:role).permit(:name, :organisation_id)
    end
end
