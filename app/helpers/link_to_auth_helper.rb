# frozen_string_literal: true

module LinkToAuthHelper
    def authorized_link_to(*args, model: nil, action: nil, **options, &block)
        if block
            text = capture(&block)
            url = args[0]
        else
            text = args[0]
            url = args[1]
        end

        # Détermine le modèle et l'action si non spécifiés
        model ||= extract_model_from_url(url)
        action ||= extract_action_from_url(url)

        if model && authorized_for?(model, action)
            link_to(text, url, options)
        else
            tag.span(text, class: "unauthorized #{options[:class]}",
                           title: 'Action non autorisée')
        end
    end

    private

    def extract_model_from_url(url)
        path = url.is_a?(String) ? url : url_for(url)
        model_name = path.split('/')[1]&.singularize&.classify
        model_name if model_name && model_name.constantize.respond_to?(:authorized_actions)
    rescue NameError
        nil
    end

    def extract_action_from_url(url)
        path = url.is_a?(String) ? url : url_for(url)
        return :show if path.match?(%r{/\d+$})
        return :edit if path.include?('/edit')
        return :new if path.include?('/new')
        return :destroy if path.match?(%r{/\d+$}) && options[:method] == :delete

        :index
    end

    def authorized_for?(model_class, action)
        return true unless model_class # Si pas de modèle trouvé, on autorise

        klass = model_class.is_a?(String) ? model_class.constantize : model_class
        return false unless klass.respond_to?(:authorized_actions)

        role = current_user&.role&.to_sym || :viewer
        klass.authorized_actions[role]&.include?(action.to_sym)
    end
end
