class HikesController < ApplicationController

    def index
        @results = fetch_hikes
    end

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

    def fetch_openrunner_details
        details = OpenrunnerFetchService.fetch_details(params[:openrunner_ref])

        if details[:error]
            render json: { error: details[:error] }, status: :unprocessable_entity
        else
            render json: details
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
            :elevation_loss,
            :altitude_min,
            :altitude_max,
            :openrunner_ref,
            :last_schedule
        )
    end

    def fetch_hikes
        Hike.with_latest_history
            .then { |scope| apply_search(scope) }
            .order_by_latest_date
            .distinct
            .includes(:hike_histories)
    end

    def apply_search(scope)
        params[:search].present? ? scope.search_by_term(params[:search]) : scope
    end
end