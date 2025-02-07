# frozen_string_literal: true

# Controller handling profile management within organizations. Profiles define sets of
# permissions that can be assigned to users, managing their access rights across
# different resources and actions within the system.
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

    ACTIONS = %w[index show create update destroy edit new].freeze

    SPECIAL_ACTIONS = {
        'ProfileRight' => %w[toggle_authorization]
    }.freeze

    def index
        @profiles = @organisation.profiles
    end

    def show
        initialize_standard_profile_rights
        initialize_special_profile_rights
    end

    def toggle_authorization
        @profile_right = ProfileRight.find(params[:id])
        if current_user.user_organisations.for_organisation&.first&.profile&.id == @profile_right.profile_id
            render json: { error: t('.cannot_modify_own_profile') }, status: :forbidden
            return
        end

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
            redirect_to profile_path(@organisation, @profile), notice: t('.success')
        else
            render :new, status: :unprocessable_entity
        end
    end

    def update
        if @profile.update(profile_params)
            redirect_to profile_path(@organisation, @profile), notice: t('.success')
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @profile.destroy
        redirect_to profiles_path(@organisation), notice: t('.success')
    end

    private

    def initialize_standard_profile_rights
        MODELS.each do |resource|
            create_profile_rights_for_resource(resource, ACTIONS)
        end
    end

    def initialize_special_profile_rights
        SPECIAL_ACTIONS.each do |resource, actions|
            create_profile_rights_for_resource(resource, actions)
        end
    end

    def create_profile_rights_for_resource(resource, actions)
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
