# frozen_string_literal: true

# Manages hiking history records including creation, updates, and listing of past
# hikes. Tracks hiking dates, guides, and associated metadata for each completed
# hike within the organization.
class HikeHistoriesController < ApplicationController
    before_action :set_members
    before_action :set_hikes, only: %i[new edit create update]
    before_action :set_hike_history, only: %i[edit update destroy]

    def index
        @hike = Hike.for_organisation.find_by(id: params[:hike_id])
        @results = fetch_hike_histories
    end

    def new
        @hike_history = HikeHistory.new
    end

    def edit; end

    def create
        @hike_history = HikeHistory.new(hike_history_params)

        if @hike_history.save
            redirect_to hikes_path, notice: t('.success')
        else
            handle_create_error
        end
    rescue ActionController::ParameterMissing
        handle_invalid_parameters
    end

    def update
        if @hike_history.update(hike_history_params)
            redirect_to hikes_path, notice: t('.success')
        else
            handle_update_error
        end
    rescue ActionController::ParameterMissing
        flash.now[:alert] = t('.invalid_params')
        render :edit, status: :unprocessable_entity
    end

    def destroy
        @hike_history.destroy
        redirect_to hikes_path, notice: t('.success')
    end

    private

    def set_members
        @members = Member.for_organisation
                         .where(role_id: 1)
                         .order(:name)
    end

    def set_hikes
        @hikes = Hike.for_organisation.order(:trail_name)
    end

    def set_hike_history
        @hike_history = HikeHistory.for_organisation.find_by(id: params[:id])
    end

    def fetch_hike_histories
        HikeHistory.for_organisation
                   .where(hike_id: params[:hike_id])
                   .joins(:member)
                   .select('hike_histories.*, members.name as member_name')
                   .order(hiking_date: :desc)
    end

    def handle_create_error
        flash.now[:alert] = t('.validation_error')
        render :new, status: :unprocessable_entity
    end

    def handle_update_error
        flash.now[:alert] = t('.validation_error')
        render :edit, status: :unprocessable_entity
    end

    def handle_invalid_parameters
        flash.now[:alert] = t('.invalid_params')
        @hike_history = HikeHistory.new
        render :new, status: :unprocessable_entity
    end

    def hike_history_params
        params.require(:hike_history).permit(
            :hiking_date,
            :departure_time,
            :day_type,
            :carpooling_cost,
            :hike_id,
            :openrunner_ref,
            :member_id
        )
    end
end
