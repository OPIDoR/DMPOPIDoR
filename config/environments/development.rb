# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'json'

# rubocop:disable Metrics/BlockLength
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = ENV.fetch('CACHE_CLASSES', false).to_s.casecmp('true').zero?

  # Do not eager load code on boot.
  config.eager_load = ENV.fetch('EAGER_LOAD', false).to_s.casecmp('true').zero?

  # Enable server timing
  config.server_timing = ENV.fetch('SERVER_TIMING', true).to_s.casecmp('true').zero?

  # Show full error reports.
  config.consider_all_requests_local = ENV.fetch('CONSIDER_ALL_REQUESTS_LOCAL', true).to_s.casecmp('true').zero?

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = ENV.fetch('ACTION_CONTROLLER_PERFORM_CACHING', true).to_s.casecmp('true').zero?
    config.action_controller.enable_fragment_cache_logging = ENV.fetch('ACTION_CONTROLLER_ENABLE_FRAGMENT_CACHE_LOGGING', true).to_s.casecmp('true').zero?

    config.cache_store = ENV.fetch('CACHE_STORE', :memory_store)&.to_sym
    config.public_file_server.headers = JSON.parse(ENV.fetch('PUBLIC_FILE_SERVER_HEADERS', {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }.to_json))
  else
    config.action_controller.perform_caching = ENV.fetch('ACTION_CONTROLLER_PERFORM_CACHING', false).to_s.casecmp('true').zero?

    config.cache_store = ENV.fetch('CACHE_STORE', :null_store)&.to_sym
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = ENV.fetch('ACTIVE_STORAGE_SERVICE', :local)&.to_sym

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = ENV.fetch('ACTION_MAILER_RAISE_DELIVERY_ERRORS', false).to_s.casecmp('true').zero?

  config.action_mailer.perform_caching = ENV.fetch('ACTION_MAILER_PERFORM_CACHING', false).to_s.casecmp('true').zero?

  # settings for mailcatcher
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

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = ENV.fetch('ACTIVE_SUPPORT_DEPRECATION', :log)&.to_sym

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', :debug)&.to_sym

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION', :raise)&.to_sym

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = JSON.parse(ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS', [].to_json))

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = ENV.fetch('ACTIVE_RECORD_MIGRATION_ERROR', :page_load)&.to_sym

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = ENV.fetch('ACTIVE_RECORD_VERBOSE_QUERY_LOGS', true).to_s.casecmp('true').zero?

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = ENV.fetch('ASSETS_DEBUG', false).to_s.casecmp('true').zero?

  # Suppress logger output for asset requests.
  config.assets.quiet = ENV.fetch('ASSETS_QUIET', true).to_s.casecmp('true').zero?

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = ENV.fetch('I18N_RAISE_ON_MISSING_TRANSLATIONS', true).to_s.casecmp('true').zero?

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = ENV.fetch('ACTION_VIEW_ANNOTATE_RENDERED_VIEW_WITH_FILENAMES', true).to_s.casecmp('true').zero?

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = ENV.fetch('ACTION_CABLE_DISABLE_REQUEST_FORGERY_PROTECTION', true).to_s.casecmp('true').zero?

  # Rails 6+ adds middleware to prevent DNS rebinding attacks:
  #    https://guides.rubyonrails.org/configuring.html#actiondispatch-hostauthorization
  #
  # This allows us to define the hostname and add it to the whitelist. If you attempt
  # to access the site and receive a 'Blocked host' error then you will need to
  # set this environment variable
  Rails.application.config.hosts = [
    IPAddr.new('0.0.0.0/0'), # All IPv4 addresses.
    IPAddr.new('::/0'), # All IPv6 addresses.
    'localhost', # The localhost reserved domain.
    'p-wilmouth.ads.intra.inist.fr',
    ENV.fetch('DMPROADMAP_HOST', 'dmpopidor') # Additional comma-separated hosts for development.
  ]
end
# rubocop:enable Metrics/BlockLength

# Used by Rails' routes url_helpers (typically when including a link in an email)
Rails.application.routes.default_url_options[:host] = ENV.fetch('DMPROADMAP_HOST', 'localhost:3000')
