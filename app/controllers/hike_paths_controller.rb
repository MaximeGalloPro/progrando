# frozen_string_literal: true

class HikePathsController < ApplicationController
    def show
        @hike_path = HikePath.for_organisation.find_by(id: params[:id])
        return unless @hike_path.nil?

        flash[:alert] = "Le tracé demandé n'existe pas."
        redirect_to hikes_path
    end

    def new
        @hike_path = session[:last_hike_path] ? HikePath.new(session[:last_hike_path]) : HikePath.new
        session.delete(:last_hike_path)
    end

    def create
        points = params[:points]
        @hike_path = HikePath.new
        if points.blank?
            @hike_path.errors.add(:points, ': Veuillez ajouter des points sur la carte.')
            return render :new, status: :unprocessable_entity
        end

        hike = Hike.for_organisation.find_by(id: params[:hike_id])
        @hike_path.assign_attributes(coordinates: points, hike_id: hike&.id)

        if @hike_path.save
            flash[:notice] = 'Tracé sauvegardé avec succès !'
            session[:last_hike_path] = @hike_path.attributes
            redirect_back fallback_location: new_hike_path
        else
            render :new, status: :unprocessable_entity
        end
    end
end
