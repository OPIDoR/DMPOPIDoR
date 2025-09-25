# frozen_string_literal: true

# New with Rails 6+, we need to define the list of locales outside the context of
# the Database since thiss runs during startup. Trying to access the DB causes
# issues with autoloading; 'DEPRECATION WARNING: Initialization autoloaded the constants ... Language'
#
# Note that the entries here must have a corresponding directory in config/locale, a
# YAML file in config/locales and should also have an entry in the DB's languages table
SUPPORTED_LOCALES = %w[en-GB fr-FR].freeze
# You can define a subset of the locales for your instance's version of Translation.io if applicable
CLIENT_LOCALES = %w[en-GB fr-FR].freeze
DEFAULT_LOCALE = ENV.fetch('DEFAULT_LOCALE', 'fr-FR')

# Here we define the translation domains for the Roadmap application, `app` will
# contain translations from the open-source repository and ignore the contents
# of the `app/views/branded` directory.  The `client` domain will
#
# When running the application, the `app` domain should be specified in your environment.
# the `app` domain will be searched first, falling back to `client`
#
# When generating the translations, the rake:tasks will need to be run with each
# domain specified in order to generate both sets of translation keys.

TranslationIO.configure do |config|
  config.api_key              = ENV.fetch('TRANSLATION_API_DMPOPIDOR', nil)
  config.source_locale        = 'en'
  config.target_locales       = SUPPORTED_LOCALES
  config.text_domain          = 'app'
  config.bound_text_domains   = %w[app client]
  config.locales_path         = Rails.root.join('config', 'locale')
end

# Setup languages
def default_locale
  DEFAULT_LOCALE
end

def available_locales
  SUPPORTED_LOCALES
end

I18n.available_locales = SUPPORTED_LOCALES

I18n.default_locale = DEFAULT_LOCALE
