class ProfileRightsController < ApplicationController
    before_action :set_profile_right
    before_action :set_profile
    before_action :set_organisation

    def toggle_authorization
        @profile_right.update(authorized: !@profile_right.authorized)

        respond_to do |format|
            format.json { render json: { authorized: @profile_right.authorized } }
        end
    end

    private

    def set_profile_right
        @profile_right = ProfileRight.find(params[:id])
    end

    def set_profile
        @profile = Profile.find(params[:profile_id])
    end

    def set_organisation
        @organisation = Organisation.find(params[:organisation_id])
    end
end