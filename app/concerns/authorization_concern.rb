# app/controllers/concerns/authorization_concern.rb
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

    def check_authorization!
        Rails.logger.debug "\n --- \e[36mCurrent user: \e[1m#{current_user&.email}\e[0m --- \n"
        Rails.logger.debug "\n --- \e[35mCurrent user profile: \e[1m#{current_user&.profile&.name}\e[0m --- \n"
        Rails.logger.debug "\n --- \e[33mController: \e[1m#{controller_path}\e[0m --- "
        Rails.logger.debug "\n --- \e[33mAction: \e[1m#{action_name}\e[0m --- \n"

        return if skip_authorization?

        resource = controller_path.classify
        action = extract_action

        authorized = can?(action, resource)
        status_color = authorized ? "\e[32m" : "\e[31m"
        model_dont_have_to_be_checked =  exclude_models.include?(resource)
        if model_dont_have_to_be_checked
            Rails.logger.debug "\n --- \e[33mNo need to check authorization for #{resource}##{action}\e[0m --- \n"
            return
        else
            Rails.logger.debug "\n --- \e[35mNeed to check authorization for #{resource}##{action}\e[0m --- \n"
        end

        Rails.logger.debug "\n --- #{status_color}Authorization check: \e[1m#{authorized}\e[0m#{status_color} for #{resource}##{action}\e[0m --- \n"

        unless authorized
            flash[:error] = "Accès non autorisé"
            redirect_to "http://localhost:3000", allow_other_host: true
        end
    end

    def skip_authorization?
        controller_path == 'sessions' || # Devise sessions
            controller_path == 'devise/sessions' ||
            controller_path == 'devise/registrations' ||
            controller_path == 'devise/passwords' ||
            (controller_path == 'stats' && action_name == 'dashboard') # Votre page d'accueil
    end

    def can?(action, resource)
        return true if current_user&.super_admin
        return false unless current_user.user_organisations.any?(&:profile)
        return true if current_user.user_organisations.for_organisation&.first&.creator
        current_user.user_organisations.find_by(organisation_id: current_user.current_organisation_id).profile.authorized_for?(resource, action)
    rescue
        false
    end

    def extract_action
        case action_name
        when 'index', 'show', 'new', 'create', 'edit', 'update', 'destroy'
            action_name
        else
            'show'
        end
    end
end