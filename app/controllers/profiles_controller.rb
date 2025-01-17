# frozen_string_literal: true

class ProfilesController < ApplicationController
    before_action :set_profile, only: %i[show edit update destroy]
    before_action :set_organisation

    MODELS = %w[User
                Organisation
                Profile
                Role
                Member
                Hike
                HikeHistory
                HikePath].freeze

    ACTION = %w[index show create update destroy edit new].freeze

    SPECIAL_ACTIONS = {
        'ProfileRight' => %w[toggle_authorization]
    }.freeze

    def index
        @profiles = @organisation.profiles
    end

    def show
        MODELS.each do |resource|
            ACTION.each do |action|
                ProfileRight.find_or_create_by(
                    profile: @profile,
                    resource: resource,
                    action: action,
                    authorized: false,
                    organisation_id: Current.organisation.id
                )
            end
        end
        SPECIAL_ACTIONS.each do |resource, actions|
            actions.each do |action|
                ProfileRight.find_or_create_by(
                    profile: @profile,
                    resource: resource,
                    action: action,
                    authorized: false,
                    organisation_id: Current.organisation.id
                )
            end
        end
    end

    def toggle_authorization
        @profile_right = ProfileRight.find(params[:id])
        @profile_right.update(authorized: !@profile_right.authorized)

        respond_to do |format|
            format.json { render json: { authorized: @profile_right.authorized } }
        end
    end

    def new
        @profile = @organisation.profiles.build
    end

    def edit; end

    def create
        @profile = @organisation.profiles.build(profile_params)

        if @profile.save
            redirect_to profile_path(@organisation, @profile), notice: 'Profil créé avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    def update
        if @profile.update(profile_params)
            redirect_to profile_path(@organisation, @profile), notice: 'Profil mis à jour avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @profile.destroy
        redirect_to profiles_path(@organisation), notice: 'Profil supprimé avec succès.'
    end

    private

    def set_profile
        @profile = Profile.find(params[:id])
    end

    def set_organisation
        @organisation = Current.organisation
    end

    def profile_params
        params.require(:profile).permit(:name, :description, :active)
    end
end
