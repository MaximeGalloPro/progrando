# app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :authenticate_user!

    def update_theme
        if current_user.update(theme: params[:user][:theme])
            redirect_back(fallback_location: root_path, notice: 'Thème mis à jour avec succès')
        else
            redirect_back(fallback_location: root_path, alert: 'Erreur lors de la mise à jour du thème')
        end
    end
end
