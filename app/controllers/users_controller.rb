# app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :get_member, only: [:edit, :update]

    def update_member
        member = current_user.members&.for_organisation&.first
        if !member.blank?
            member.update(name: params[:user][:name], email: params[:user][:email],
                           phone: params[:user][:phone], organisation: Current.organisation)
        else
            @member = Member.create(name: params[:user][:name], email: params[:user][:email],
                                    phone: params[:user][:phone], organisation: Current.organisation)
            UserMember.create(user: current_user, member: @member)
        end
        redirect_back(fallback_location: edit_user_registration_path, notice: 'Informations mise à jour avec succès')
    end

    def update_theme
        if current_user.update(theme: params[:user][:theme])
            redirect_back(fallback_location: edit_user_registration_path, notice: 'Thème mis à jour avec succès')
        else
            redirect_back(fallback_location: edit_user_registration_path, alert: 'Erreur lors de la mise à jour du thème')
        end
    end

    private

    def get_member
        @member = current_user&.members&.for_organisation&.first || Member.new
    end
end
