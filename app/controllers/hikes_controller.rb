class HikesController < ApplicationController

    # app/controllers/hikes_controller.rb
    # app/controllers/hikes_controller.rb
    def refresh_from_openrunner
        @hike = Hike.find(params[:id])
        UpdateHikeFromOpenrunnerJob.perform_later(@hike)

        # Redirection avec les paramètres de recherche
        redirect_back_options = { notice: "Mise à jour des données depuis OpenRunner en cours..." }

        # Si on a un paramètre de recherche, on le conserve
        if params[:search].present?
            redirect_back_options[:search] = params[:search]
        end

        redirect_to hikes_path(redirect_back_options), status: :see_other
    end

    def index
        @results = Hike
                       .joins("LEFT JOIN (
            SELECT hike_histories.*
            FROM hike_histories
            INNER JOIN (
                SELECT hike_number, MAX(hiking_date) as max_date
                FROM hike_histories
                GROUP BY hike_number
            ) latest
            ON hike_histories.hike_number = latest.hike_number
            AND hike_histories.hiking_date = latest.max_date
        ) last_history ON hikes.number = last_history.hike_number")

        if params[:search].present?
            search_term = params[:search].strip
            @results = @results
                           .where("hikes.trail_name LIKE :search
                   OR hikes.starting_point LIKE :search
                   OR CAST(hikes.number AS CHAR) LIKE :search
                   OR last_history.guide_name LIKE :search",
                                  search: "%#{search_term}%")
        end

        @results = @results.order("last_history.hiking_date ASC").distinct
    end

    def new
        @hike = Hike.new
    end

    def create
        @hike = Hike.new(hike_params)
        if @hike.save
            redirect_to hikes_path, notice: 'Parcours ajouté avec succès.'
        else
            render :new, status: :unprocessable_entity
        end
    end

    private

    def hike_params
        params.require(:hike).permit(
            :number,
            :day,
            :difficulty,
            :starting_point,
            :trail_name,
            :carpooling_cost,
            :distance_km,
            :elevation_gain,
            :openrunner_ref,
            :last_schedule
        )
    end
end