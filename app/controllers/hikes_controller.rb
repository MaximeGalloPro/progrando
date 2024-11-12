class HikesController < ApplicationController
    def index
        @results = Hike.all

        if params[:trail_name].present? || params[:starting_point].present?
            @results = @results.where("trail_name LIKE ?", "%#{params[:trail_name]}%") if params[:trail_name].present?
            @results = @results.where("starting_point LIKE ?", "%#{params[:starting_point]}%") if params[:starting_point].present?
        else
            @results = Hike.none
        end
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