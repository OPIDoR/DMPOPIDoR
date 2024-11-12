# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'json'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, { url: ENV.fetch('REDIS_URL', 'localhost') }

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger           = ActiveSupport::Logger.new(STDOUT, shift_age = 'daily')
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
