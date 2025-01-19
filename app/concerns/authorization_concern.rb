# frozen_string_literal: true

# Provides authorization functionality for controllers, managing access control
# based on user roles and permissions. Handles authorization checks, logging,
# and access control for different resources and actions.
module AuthorizationConcern
    extend ActiveSupport::Concern

    included do
        helper_method :can?
        before_action :check_authorization!
    end

    private

    def exclude_models
        []
    end

    def exclude_actions
        {
            'Organisation' => %w[index show new create],
            'OrganisationAccessRequest' => %w[edit destroy],
            'User' => %w[index show edit update]
        }
    end

    def check_authorization!
        log_authorization_context
        return if skip_authorization?
        return if exclude_from_authorization?

        resource = controller_path.classify
        action = extract_action

        log_authorization_requirement(resource, action)
        verify_authorization(resource, action)
    end

    def log_authorization_context
        Rails.logger.debug { "\n --- \e[36mCurrent user: \e[1m#{current_user&.email}\e[0m --- \n" }
        Rails.logger.debug { "\n --- \e[35mCurrent user profile: \e[1m#{current_user&.profile&.name}\e[0m --- \n" }
        Rails.logger.debug { "\n --- \e[33mController: \e[1m#{controller_path}\e[0m --- " }
        Rails.logger.debug { "\n --- \e[33mAction: \e[1m#{action_name}\e[0m --- \n" }
    end

    def exclude_from_authorization?
        resource = controller_path.classify
        action = extract_action

        model_excluded = exclude_models.include?(resource)
        action_excluded = exclude_actions[resource]&.include?(action)

        if model_excluded || action_excluded
            log_exclusion(resource, action)
            true
        else
            false
        end
    end

    def log_exclusion(resource, action)
        Rails.logger.debug { "\n --- \e[33mNo need to check authorization for #{resource}##{action}\e[0m --- \n" }
    end

    def log_authorization_requirement(resource, action)
        Rails.logger.debug { "\n --- \e[35mNeed to check authorization for #{resource}##{action}\e[0m --- \n" }
    end

    def verify_authorization(resource, action)
        authorized = can?(action, resource)
        log_authorization_result(authorized, resource, action)

        return if authorized

        handle_unauthorized_access
    end

    def log_authorization_result(authorized, resource, action)
        status_color = authorized ? "\e[32m" : "\e[31m"
        Rails.logger.debug do
            "\n --- #{status_color}Authorization check: \e[1m#{authorized}\e[0m#{status_color} for #{resource}##{action}\e[0m --- \n"
        end
    end

    def handle_unauthorized_access
        flash[:error] = t('authorization.unauthorized_access')
        redirect_to 'http://localhost:3000', allow_other_host: true
    end

    def skip_authorization?
        devise_controller? || dashboard_action?
    end

    def devise_controller?
        %w[sessions devise/sessions devise/registrations devise/passwords].include?(controller_path)
    end

    def dashboard_action?
        controller_path == 'stats' && action_name == 'dashboard'
    end

    def can?(action, resource)
        return true if super_admin_access?
        return false unless user_has_profile?
        return true if creator_access?
        if resource == 'Organisation' && @organisation.present?
            return false unless current_user.user_organisations.exists?(organisation: @organisation)
        end

        check_profile_authorization(action, resource)
    rescue StandardError
        false
    end

    def super_admin_access?
        current_user&.super_admin
    end

    def user_has_profile?
        current_user.user_organisations.any?(&:profile)
    end

    def creator_access?
        current_user.user_organisations.for_organisation&.first&.creator
    end

    def check_profile_authorization(action, resource)
        user_organisation = current_user.user_organisations.find_by(
            organisation_id: current_user.current_organisation_id
        )

        user_organisation.profile.authorized_for?(resource, action)
    end

    def extract_action
        return action_name if standard_action?

        'show'
    end

    def standard_action?
        %w[index show new create edit update destroy].include?(action_name)
    end
end
