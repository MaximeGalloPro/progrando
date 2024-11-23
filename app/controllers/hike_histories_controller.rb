class HikeHistoriesController < ApplicationController

    def index
        @hike = Hike.find_by(number: params[:hike_number])
        @results = HikeHistory.where(hike_number: params[:hike_number])
                              .joins(:guide)
                              .select('hike_histories.*, guides.name as guide_name')
                              .order(hiking_date: :desc)
    end

    def new
        @hike_history = HikeHistory.new
        @hikes = Hike.order(:trail_name)
        @guides = Guide.all.order(:name)
    end

    def edit
        @hike_history = HikeHistory.find(params[:id])
        @hikes = Hike.order(:trail_name)
        @guides = Guide.all.order(:name)
    end

    def create
        @hike_history = HikeHistory.new(hike_history_params)

        if @hike_history.save
            redirect_to hikes_path, notice: 'Randonnée ajoutée à l\'historique avec succès.'
        else
            @hikes = Hike.order(:trail_name)
            @guides = Guide.all.order(:name)  # Ajout de cette ligne
            flash.now[:alert] = 'Veuillez corriger les erreurs ci-dessous.'
            render :new, status: :unprocessable_entity
        end
    rescue ActionController::ParameterMissing
        flash.now[:alert] = 'Données de formulaire invalides.'
        @hikes = Hike.order(:trail_name)
        @guides = Guide.all.order(:name)  # Ajout de cette ligne aussi
        @hike_history = HikeHistory.new
        render :new, status: :unprocessable_entity
    end

    private

    def hike_history_params
        params.require(:hike_history).permit(
            :hiking_date,
            :departure_time,
            :day_type,
            :carpooling_cost,
            :hike_number,
            :openrunner_ref,
            :guide_id  # Ajout de guide_id
        )
    end
end