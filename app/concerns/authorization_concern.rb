# app/controllers/concerns/authorization_concern.rb
module AuthorizationConcern
    extend ActiveSupport::Concern

    included do
        helper_method :can?
        before_action :check_authorization!
    end

    private

    def check_authorization!
        Rails.logger.debug "Current user: #{current_user&.email}"
        Rails.logger.debug "Current user profile: #{current_user&.profile&.name}"
        Rails.logger.debug "Controller: #{controller_path}"
        Rails.logger.debug "Action: #{action_name}"

        return if skip_authorization?

        resource = controller_path.classify
        action = extract_action

        authorized = can?(action, resource)
        Rails.logger.debug "Authorization check: #{authorized} for #{resource}##{action}"

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