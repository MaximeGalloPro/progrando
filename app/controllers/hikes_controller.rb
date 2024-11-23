class HikesController < ApplicationController

    def index
        @results = fetch_hikes
    end

    def refresh_from_openrunner
        @hike = Hike.find(params[:id])
        @hike.update(updating: true)
        UpdateHikeFromOpenrunnerJob.perform_later(@hike)

        # Redirection avec les paramètres de recherche
        redirect_back_options = { notice: "Mise à jour des données depuis OpenRunner en cours..." }

        # Si on a un paramètre de recherche, on le conserve
        redirect_back_options = {
            notice: "La randonnée \"#{@hike.trail_name}\" est en cours de mise à jour depuis OpenRunner..."
        }

        # Gestion des paramètres de redirection
        if params[:search].present?
            redirect_back_options[:search] = params[:search]
        elsif params[:redirect_path].present?
            redirect_back_options[:redirect_path] = params[:redirect_path]
        else
            redirect_back_options[:search] = nil
        end

        # Redirection avec les options
        redirect_back(fallback_location: hikes_path, **redirect_back_options)
    end

    def new
        @hike = Hike.new
    end

    def edit
        @hike = Hike.find(params[:id])
    end

    def update
        @hike = Hike.find(params[:id])
        if @hike.update(hike_params)
            redirect_to hikes_path, notice: 'Parcours mis à jour avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
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

    def destroy
        @hike = Hike.find(params[:id])
        @hike.destroy
        redirect_to hikes_path, notice: 'Parcours supprimé avec succès.'
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