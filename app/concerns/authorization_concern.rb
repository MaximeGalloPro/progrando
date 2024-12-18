# app/controllers/concerns/authorization_concern.rb
module AuthorizationConcern
    extend ActiveSupport::Concern

    included do
        helper_method :can?
        before_action :check_authorization!
    end

    private

    def check_authorization!
        Rails.logger.debug "\e[36mCurrent user: \e[1m#{current_user&.email}\e[0m"
        Rails.logger.debug "\e[35mCurrent user profile: \e[1m#{current_user&.profile&.name}\e[0m"
        Rails.logger.debug "\e[33mController: \e[1m#{controller_path}\e[0m"
        Rails.logger.debug "\e[33mAction: \e[1m#{action_name}\e[0m"

        return if skip_authorization?

        resource = controller_path.classify
        action = extract_action

        authorized = can?(action, resource)
        status_color = authorized ? "\e[32m" : "\e[31m"
        Rails.logger.debug "#{status_color}Authorization check: \e[1m#{authorized}\e[0m#{status_color} for #{resource}##{action}\e[0m"

        unless authorized
            flash[:error] = "Accès non autorisé"
            redirect_to root_path
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
        return false unless current_user&.profile
        current_user.profile.authorized_for?(resource, action)
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