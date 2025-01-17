# frozen_string_literal: true

# Helper methods for application-wide functionality including authorization checks,
# link generation, and status translation. Provides utilities for managing resource
# access, path manipulation, and localization support.
module ApplicationHelper
    def show_if_authorized(resource, action)
        # Retourne true/false au lieu de yield/nil
        if current_user&.super_admin || can?(action, resource)
            yield if block_given?
            true
        else
            false
        end
    end

    def link_to_if_authorized(name, options = {}, html_options = {}, &)
        resource = extract_resource_from_path(options)
        action = extract_action_from_path(options)
        return unless can?(action, resource)

        link_to(name, options, html_options, &)
    end

    private

    def extract_resource_from_path(options)
        case options
        when String
            extract_from_string_path(options)
        else
            extract_from_options_hash(options)
        end
    end

    def extract_from_string_path(path)
        segments = path.split('/')
        resource_name = segments.find { |segment| segment.present? && !segment.match?(/^\d+$/) }
        resource_name&.singularize&.classify || ''
    end

    def extract_from_options_hash(options)
        path = options[:controller] || url_for(options)
        extract_from_string_path(path)
    end

    def extract_action_from_path(options)
        return 'destroy' if options.is_a?(Hash) && options[:method] == :delete
        return 'create' if options.to_s.include?('/new')
        return 'update' if options.to_s.include?('/edit')

        'show'
    end

    def with_subdomain(organisation, options = {})
        subdomain = organisation.try(:slug)
        options[:subdomain] = subdomain if subdomain.present?
        options
    end

    def translate_status(status)
        {
            'pending' => 'En attente',
            'approved' => 'Approuvé',
            'rejected' => 'Rejeté'
        }[status]
    end
end
