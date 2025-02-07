# frozen_string_literal: true

# app/controllers/users_controller.rb
class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :set_member, only: %i[edit update]

    def edit
        # Explicit action definition for lexically scoped filter
    end

    def update
        # Explicit action definition for lexically scoped filter
    end

    def update_member
        member = find_or_initialize_member

        if member.update(member_params)
            create_user_member(member) if member.new_record?
            redirect_back_with_success(:member_update_success)
        else
            redirect_back_with_error(:member_update_error)
        end
    end

    def update_theme
        if current_user.update(theme_params)
            redirect_back_with_success(:theme_update_success)
        else
            redirect_back_with_error(:theme_update_error)
        end
    end

    private

    def set_member
        @member = find_current_member || Member.new
    end

    def find_current_member
        current_user.then do |user|
            user.members.then do |members|
                members.for_organisation.first
            end
        end
    end

    def find_or_initialize_member
        find_current_member || Member.new(organisation: Current.organisation)
    end

    def create_user_member(member)
        UserMember.create(user: current_user, member: member)
    end

    def member_params
        params.require(:user).permit(:name, :email, :phone).merge(organisation: Current.organisation)
    end

    def theme_params
        params.require(:user).permit(:theme)
    end

    def redirect_back_with_success(key)
        redirect_back(
            fallback_location: edit_user_registration_path,
            notice: t(".#{key}")
        )
    end

    def redirect_back_with_error(key)
        redirect_back(
            fallback_location: edit_user_registration_path,
            alert: t(".#{key}")
        )
    end
end
