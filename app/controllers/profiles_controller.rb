class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action :set_organisation

  def index
    @profiles = @organisation.profiles
  end

  def show
  end

  def new
    @profile = @organisation.profiles.build
  end

  def edit
  end

  def create
    @profile = @organisation.profiles.build(profile_params)

    if @profile.save
      redirect_to organisation_profile_path(@organisation, @profile), notice: 'Profil créé avec succès.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to organisation_profile_path(@organisation, @profile), notice: 'Profil mis à jour avec succès.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @profile.destroy
    redirect_to organisation_profiles_path(@organisation), notice: 'Profil supprimé avec succès.'
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def set_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def profile_params
    params.require(:profile).permit(:name, :description, :active)
  end
end