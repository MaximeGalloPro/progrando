class HikeHistoriesController < ApplicationController
    def new
        @hike_history = HikeHistory.new
        @hikes = Hike.order(:trail_name)
    end

    def create
        @hike_history = HikeHistory.new(hike_history_params)

        if @hike_history.save
            redirect_to hikes_path, notice: 'Randonnée ajoutée à l\'historique avec succès.'
        else
            @hikes = Hike.order(:trail_name)
            flash.now[:alert] = 'Veuillez corriger les erreurs ci-dessous.'
            render :new, status: :unprocessable_entity
        end
    rescue ActionController::ParameterMissing
        flash.now[:alert] = 'Données de formulaire invalides.'
        @hikes = Hike.order(:trail_name)
        @hike_history = HikeHistory.new
        render :new, status: :unprocessable_entity
    end

    private

    def hike_history_params
        params.require(:hike_history).permit(
            :hiking_date,
            :departure_time,
            :day_type,
            :difficulty,
            :starting_point,
            :trail_name,
            :carpooling_cost,
            :distance_km,
            :elevation_gain,
            :guide_name,
            :guide_phone,
            :hike_number,
            :openrunner_ref
        )
    end
end