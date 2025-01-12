# app/controllers/users_controller.rb
class UsersController::RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_user!
    before_action :set_member, only: [:edit, :update]

    def edit
    end

    def update_theme
        if current_user.update(theme: params[:user][:theme])
            redirect_back(fallback_location: edit_user_registration_path, notice: 'Thème mis à jour avec succès')
        else
            redirect_back(fallback_location: edit_user_registration_path, alert: 'Erreur lors de la mise à jour du thème')
        end
    end

    private

    def set_member
        @member = current_user&.members&.for_organisation&.first || Member.new
    end

    def update_member
        if !@member.persisted?
            @member.update(name: params[:name], email: params[:email],
                           phone: params[:phone], organisation: @organisation)
        else
            @member = Member.create(name: params[:name], email: params[:email],
                                    phone: params[:phone], organisation: @organisation)
            UserMember.create(user: current_user, member: @member)
        end
    end
end
