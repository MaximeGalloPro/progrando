module ApplicationHelper
    def show_if_authorized(resource, action, &block)
        # Retourne true/false au lieu de yield/nil
        if current_user&.super_admin or can?(action, resource)
            yield if block_given?
            true
        else
            false
        end
    end

    def link_to_if_authorized(name, options = {}, html_options = {}, &block)
        resource = extract_resource_from_path(options)
        action = extract_action_from_path(options)
        if can?(action, resource)
            link_to(name, options, html_options, &block)
        end
    end

    private

    def extract_resource_from_path(options)
        path = options.is_a?(String) ? options : (options[:controller] || url_for(options))
        # Extrait le premier segment de l'URL qui n'est pas un nombre
        segments = path.split('/')
        resource_name = segments.find { |segment| segment.present? && !segment.match?(/^\d+$/) }
        resource_name&.singularize&.classify || ''
    end

    def extract_action_from_path(options)
        return 'destroy' if options.is_a?(Hash) && options[:method] == :delete
        return 'create' if options.to_s.include?('/new')
        return 'update' if options.to_s.include?('/edit')
        'show'
    end

    def with_subdomain(organisation, options = {})
        subdomain = organisation.try(:slug)
        options.merge!(subdomain: subdomain) if subdomain.present?
        options
    end
end