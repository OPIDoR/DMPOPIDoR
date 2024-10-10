# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'json'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = ENV.fetch('CACHE_CLASSES', false).to_s.casecmp('true').zero?

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = ENV.fetch('EAGER_LOAD', false).to_s.casecmp('true').zero?

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local = ENV.fetch('CONSIDER_ALL_REQUESTS_LOCAL', false).to_s.casecmp('true').zero?
  config.action_controller.perform_caching = ENV.fetch('ACTION_CONTROLLER_PERFORM_CACHING', true).to_s.casecmp('true').zero?

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = ENV.fetch('REQUIRE_MASTER_KEY', true).to_s.casecmp('true').zero?

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  # config.assets.css_compressor = ENV.fetch('ASSETS_CSS_COMPRESSOR', :sass)&.to_sym

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = ENV.fetch('ASSETS_COMPILE', false).to_s.casecmp('true').zero?

  # `config.assets.precompile` and `config.assets.version` have moved to
  # config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = ENV.fetch('ACTION_CONTROLLER_ASSET_HOST', 'http://assets.example.com')

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = ENV.fetch('ACTION_DISPACTH_X_SENDFILE_HEADER', 'X-Sendfile') # 'X-Sendfile' for Apache / 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = ENV.fetch('ACTION_STORAGE_SERVICE', :local)&.to_sym

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = ENV.fetch('ACTION_CABLE_MOUNT_PATH', nil)
  # config.action_cable.url = ENV.fetch('ACTION_CABLE_URL', 'wss://example.com/cable')
  # config.action_cable.allowed_request_origins = JSON.parse(ENV.fetch('ACTION_CABLE_ALLOWRD_REQUEST_ORIGINS', [ 'http://example.com', /http:\/\/example.*/ ].to_json))

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = ENV.fetch('FORCE_SSL', true).to_s.casecmp('true').zero?

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', :info)&.to_sym

  # Prepend all log lines with the following tags.
  config.log_tags = [ENV.fetch('LOG_TAGS', :request_id)&.to_sym]

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL', 'localhost') }

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = ENV.fetch('ACTIVE_JOB_QUEUE_NAME_PREFIX', 'dmp_roadmap_#{Rails.env}')

  config.action_mailer.perform_caching = ENV.fetch('ACTION_MAILER_PERFORM_CACHING', false).to_s.casecmp('true').zero?

  # settings for mailcatcher
  config.action_mailer.default_url_options = {
    :host => ENV.fetch('DMPROADMAP_HOST', 'dmp.opidor.fr'),
    :protocol => ENV.fetch('ACTION_MAILER_DEFAULT_URL_OPTIONS_PROTOCOL', 'https')
  }
  config.action_mailer.delivery_method = ENV.fetch('ACTION_MAILER_DELIVERY_METHOD', :smtp)&.to_sym
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('ACTION_MAILER_SMTP_HOST', 'mailcatcher'),
    port: ENV.fetch('ACTION_MAILER_SMTP_PORT', 1025)
  }

  ActionMailer::Base.default :from => ENV.fetch('MAILER_FROM', 'dmp.opidor@inist.fr')
  ActionMailer::Base.delivery_method = ENV.fetch('ACTION_MAILER_DELIVERY_METHOD', :smtp)&.to_sym
  ActionMailer::Base.smtp_settings = {
    address: ENV.fetch('ACTION_MAILER_SMTP_HOST', 'mailcatcher'),
    port: ENV.fetch('ACTION_MAILER_SMTP_PORT', 1025)
  }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = ENV.fetch('ACTION_MAILER_RAISE_DELIVERY_ERRORS', false).to_s.casecmp('true').zero?

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = ENV.fetch('I18N_FALLBACKS', true).to_s.casecmp('true').zero?

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = ENV.fetch('ACTIVE_SUPPORT_DEPRECATION', :notify)&.to_sym

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION', :log)&.to_sym

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = JSON.parse(ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS', [].to_json))

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = ENV.fetch('ACTIVE_RECORD_DUMP_SCHEMA_AFTER_MIGRATION', false).to_s.casecmp('true').zero?

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = JSON.parse(ENV.fetch('ACTIVE_RECORD_DATABSE_SELECTOR', { delay: 2.seconds }.to_json))
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

  # Rails 6+ adds middleware to prevent DNS rebinding attacks:
  #    https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
  #
  # This allows us to define the hostname and add it to the whitelist. If you attempt
  # to access the site and receive a 'Blocked host' error then you will need to
  # set this environment variable
  config.hosts << ENV.fetch('DMPROADMAP_HOST', 'dmpopidor') # Additional comma-separated hosts for development.
end
# Used by Rails' routes url_helpers (typically when including a link in an email)
Rails.application.routes.default_url_options[:host] = ENV.fetch('DMPROADMAP_HOST', 'dmp.opidor.fr')
