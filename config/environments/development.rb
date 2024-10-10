# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'json'

# rubocop:disable Metrics/BlockLength
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Enable server timing
  config.server_timing = ENV.fetch('SERVER_TIMING', true).to_s.casecmp('true').zero?

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

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.file_watcher = ActiveSupport::FileUpdateChecker

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Precompile additional assets
	config.assets.precompile += %w( .svg .eot .woff .ttf )

  config.action_mailer.perform_deliveries = true

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
    ENV.fetch('DMPROADMAP_HOST', 'dmpopidor') # Additional comma-separated hosts for development.
  ]
end
# rubocop:enable Metrics/BlockLength

