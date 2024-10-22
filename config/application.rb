# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

require 'csv'
require 'grover'

require 'json'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DMPRoadmap
  # DMPRoadmap application
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults ENV.fetch('RAILS_LOAD_DEFAULTS', 7.0)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # --------------------------------- #
    # OVERRIDES TO DEFAULT RAILS CONFIG #
    # --------------------------------- #
    config.autoload_lib(ignore: %w[tasks])

    # CVE-2022-32224: add some compatibility with YAML.safe_load
    # Rails 5,6,7 are using YAML.safe_load as the default YAML deserializer
    config.active_record.yaml_column_permitted_classes = [ActiveSupport::HashWithIndifferentAccess, Symbol, Date, Time]

    # Have Zeitwerk skip generators because the generator templates are
    # incompatible with the Rails module/class naming conventions
    Rails.autoloaders.main.ignore(config.root.join('lib/generators'))

    # HTML tags that are allowed to pass through `sanitize`.
    config.action_view.sanitized_allowed_tags = %w[
      p br strong em a table thead tbody tr td th tfoot caption ul ol li
    ]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [ENV.fetch('APPLICATION_FILTER_PARAMETERS', :password)&.to_sym]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = ENV.fetch('ESCAPE_HTML_ENTITIES_IN_JSON',
                                                                   true).to_s.casecmp('true').zero?

    # Allow controllers to access view helpers
    # TODO: We should see what methods specifically are used by the controllers
    #       and include them specifically in the controllers. We should also consider
    #       moving our helper methods into Presenters if it makes sense
    config.action_controller.include_all_helpers = ENV.fetch('ACTION_CONTROLLER_INCLUDE_ALL_HELPERS',
                                                             true).to_s.casecmp('true').zero?

    smtp_setting = {
      address: ENV.fetch('ACTION_MAILER_SMTP_HOST', 'mailcatcher'),
      port: ENV.fetch('ACTION_MAILER_SMTP_PORT', 1025)
    }

    # Set the default host for mailer URLs
    # config.action_mailer.default_url_options = { host: Socket.gethostname.to_s }
    config.action_mailer.default_url_options = {
      :host => ENV.fetch('DMPROADMAP_HOST', 'dmpopidor'),
      :protocol => ENV.fetch('ACTION_MAILER_DEFAULT_URL_OPTIONS_PROTOCOL', 'https')
    }
    config.action_mailer.smtp_settings = smtp_setting
    config.action_mailer.default_options = { :from => ENV.fetch('MAILER_FROM', 'no-reply@email.address') }

    ActionMailer::Base.default :from => ENV.fetch('MAILER_FROM', 'no-reply@email.address')
    ActionMailer::Base.delivery_method = ENV.fetch('ACTION_MAILER_DELIVERY_METHOD', :smtp)&.to_sym
    ActionMailer::Base.smtp_settings = smtp_setting

    # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
    # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
    config.require_master_key = ENV.fetch('REQUIRE_MASTER_KEY', true).to_s.casecmp('true').zero?

    config.eager_load = ENV.fetch('EAGER_LOAD', false).to_s.casecmp('true').zero?

    config.cache_classes = ENV.fetch('CACHE_CLASSES', false).to_s.casecmp('true').zero?

    config.action_view.cache_template_loading = ENV.fetch('ACTION_VIEW_CACHE_TEMPLATE_LOADING',
                                                          true).to_s.casecmp('true').zero?

    config.public_file_server.enabled = ENV.fetch('PUBLIC_FILE_SERVER_ENABLED', true).to_s.casecmp('true').zero?

    # Disable fragment caching used in ExternalApis and OrgSelection services
    config.cache_store = ENV.fetch('CACHE_STORE', :null_store)&.to_sym
    config.public_file_server.headers = JSON.parse(ENV.fetch('PUBLIC_FILE_SERVER_HEADERS', {
      'Cache-Control' => "public, max-age=#{1.year.to_i}"
    }.to_json), symbolize_names: true)

    # Full error reports are disabled and caching is turned on.
    config.consider_all_requests_local = ENV.fetch('CONSIDER_ALL_REQUESTS_LOCAL', false).to_s.casecmp('true').zero?

    # Enable/disable caching. By default caching is disabled.
    # Run rails dev:cache to toggle caching.
    if Rails.root.join('tmp', 'caching-dev.txt').exist?
      config.action_controller.perform_caching = ENV.fetch('ACTION_CONTROLLER_PERFORM_CACHING',
                                                           true).to_s.casecmp('true').zero?
      config.action_controller.enable_fragment_cache_logging = ENV.fetch(
        'ACTION_CONTROLLER_ENABLE_FRAGMENT_CACHE_LOGGING', true
      ).to_s.casecmp('true').zero?
    else
      config.action_controller.perform_caching = ENV.fetch('ACTION_CONTROLLER_PERFORM_CACHING',
                                                           false).to_s.casecmp('true').zero?
    end

    # Raise exceptions instead of rendering exception templates.
    config.action_dispatch.show_exceptions = ENV.fetch('ACTION_DISPATCH_SHOW_EXCEPTIONS',
                                                       false).to_s.casecmp('true').zero?

    config.action_controller.allow_forgery_protection = ENV.fetch('ACTION_CONTROLLER_ALLOW_FORGERY_PROTECTION',
                                                                  false).to_s.casecmp('true').zero?

    # Store uploaded files on the local file system (see config/storage.yml for options)
    config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', :local)&.to_sym

    config.action_mailer.perform_caching = ENV.fetch('ACTION_MAILER_PERFORM_CACHING', false).to_s.casecmp('true').zero?

    config.action_mailer.delivery_method = ENV.fetch('ACTION_MAILER_DELIVERY_METHOD', :smtp)&.to_sym

    # Send deprecation notices to registered listeners.
    config.active_support.deprecation = ENV.fetch('ACTIVE_SUPPORT_DEPRECATION', :notify)&.to_sym

    # Log disallowed deprecations.
    config.active_support.disallowed_deprecation = ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION', :log)&.to_sym

    # Tell Active Support which deprecation messages to disallow.
    config.active_support.disallowed_deprecation_warnings = JSON.parse(
      ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS', [].to_json), symbolize_names: true
    )

    # Do not fallback to assets pipeline if a precompiled asset is missed.
    config.assets.compile = ENV.fetch('ASSETS_COMPILE', false).to_s.casecmp('true').zero?

    # Use the lowest log level to ensure availability of diagnostic information
    # when problems arise.
    config.log_level = ENV.fetch('RAILS_LOG_LEVEL', :info)&.to_sym

    # Prepend all log lines with the following tags.
    config.log_tags = [ENV.fetch('LOG_TAGS', :request_id)&.to_sym]

    # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
    # the I18n.default_locale when a translation cannot be found).
    config.i18n.fallbacks = ENV.fetch('I18N_FALLBACKS', true).to_s.casecmp('true').zero?
    config.i18n.enforce_available_locales = ENV.fetch('I18N_ENFORCE_AVAILABLE_LOCALES', true).to_s.casecmp('true').zero?

    # Do not dump schema after migrations.
    config.active_record.dump_schema_after_migration = ENV.fetch('ACTIVE_RECORD_DUMP_SCHEMA_AFTER_MIGRATION',
                                                                 false).to_s.casecmp('true').zero?

    # Ignore bad email addresses and do not raise email delivery errors.
    # Set this to true and configure the email server for immediate delivery to raise delivery errors.
    config.action_mailer.raise_delivery_errors = ENV.fetch('ACTION_MAILER_RAISE_DELIVERY_ERRORS',
                                                           true).to_s.casecmp('true').zero?

    # Mount Action Cable outside main process or domain
    config.action_cable.url = ENV.fetch('ACTION_CABLE_URL', 'ws://localhost:8080/cable')
    config.action_cable.mount_path = ENV.fetch('ACTION_CABLE_MOUNT_PATH', '/cable')
    config.action_cable.allowed_request_origins = JSON.parse(ENV.fetch('ACTION_CABLE_ALLOWED_REQUEST_ORIGINS',
                                                                       '[ "http://example.com", "/http:\/\/example.*/" ]')) # rubocop:disable Layout/LineLength
    config.action_cable.disable_request_forgery_protection = ENV.fetch(
      'ACTION_CABLE_DISABLE_REQUEST_FORGERY_PROTECTION', true
    ).to_s.casecmp('true').zero?

    allowed_origins = ENV.fetch('ALLOWED_HOSTS', 'dmpopidor').split(',')
    config.action_cable.allowed_request_origins = allowed_origins.is_a?(Array) ? allowed_origins : [allowed_origins]

    # Use default logging formatter so that PID and timestamp are not suppressed.
    config.log_formatter = Logger::Formatter.new

    if ENV['RAILS_LOG_TO_STDOUT'].present?
      logger           = ActiveSupport::Logger.new($stdout)
      logger.formatter = config.log_formatter
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
    end

    # Error notifications by email
    if ENV['ERROR_NOTIFICATION_EMAIL'].present?
      config.middleware.use ExceptionNotification::Rack, :email => {
        :email_prefix => ENV.fetch('ERROR_NOTIFICATION_EMAIL_PREFIX', '[DMPOPIDoR ERROR]'),
        :sender_address => ENV.fetch('ERROR_NOTIFICATION_SENDER_ADDRESS', %("No-reply" <noreply@example.com>)),
        :exception_recipients => ENV.fetch('ERROR_NOTIFICATION_EXCEPTION_RECIPIENTS',
                                           %w[exception-recipients@email.address])
      }
    end

    # Rails 6+ adds middleware to prevent DNS rebinding attacks:
    #    https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
    #
    # This allows us to define the hostname and add it to the whitelist. If you attempt
    # to access the site and receive a 'Blocked host' error then you will need to
    # set this environment variable
    config.hosts << ENV.fetch('ALLOWED_HOSTS', 'dmpopidor')
  end
end

# Used by Rails' routes url_helpers (typically when including a link in an email)
Rails.application.routes.default_url_options[:host] = ENV.fetch('DMPROADMAP_HOST', 'dmpopidor')
