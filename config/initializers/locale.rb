# frozen_string_literal: true

# Where the I18n library should search for translation files
I18n.load_path += Rails.root.glob('lib/locale/*.{rb,yml}')

# Whitelist locales available for the application
I18n.available_locales = %i[en fr]

# Set French as default locale
I18n.default_locale = :fr
