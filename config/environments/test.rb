# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'json'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = ENV.fetch('CACHE_CLASSES', false) == 'true'
  config.action_view.cache_template_loading = ENV.fetch('ACTION_VIEW_CACHE_TEMPLATE_LOADING', true) == 'true'

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = ENV.fetch('PUBLIC_FILE_SERVER_ENABLED', true) == 'true'
  config.public_file_server.headers = JSON.parse(ENV.fetch('PUBLIC_FILE_SERVER_HEADERS', {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }.to_json))

  # Disable fragment caching used in ExternalApis and OrgSelection services
  config.cache_store = :null_store

  # Show full error reports and disable caching.
  config.consider_all_requests_local = ENV.fetch('CONSIDER_ALL_REQUESTS_LOCAL', true) == 'true'
  config.action_controller.perform_caching = ENV.fetch('ACTION_CONTROLLER_PERFORM_CACHING', false)  == 'true'

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = ENV.fetch('ACTION_DISPATCH_SHOW_EXCEPTIONS', false)  == 'true'

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = ENV.fetch('ACTION_CONTROLLER_ALLOW_FORGERY_PROTECTION', false)  == 'true'

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = ENV.fetch('ACTION_MAILER_PERFORM_CACHING', false) == 'true'

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = JSON.parse(ENV.fetch('ACTIVE_SUPPORT_DISALLOWED_DEPRECATION_WARNINGS', [].to_json))

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = ENV.fetch('I18N_RAISE_ON_MISSING_TRANSLATIONS', true) == 'true'

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = ENV.fetch('ACTION_VIEW_ANNOTATE_RENDERED_VIEW_WITH_FILENAMES', true) == 'true'

  config.i18n.enforce_available_locales = ENV.fetch('I18N_ENFORCE_AVAILABLE_LOCALES', false) == 'true'
end

# Used by Rails' routes url_helpers (typically when including a link in an email)
Rails.application.routes.default_url_options[:host] = ENV.fetch('APPLICATION_ROUTES_DEFAULT_URL_OPTIONS', 'example.org')
