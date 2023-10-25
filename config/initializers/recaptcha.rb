# frozen_string_literal: true

require 'recaptcha/rails'

# the keys are set in config/credentials.yml.env

Recaptcha.configure do |config|
  config.site_key = ENV.fetch('RECAPTCHA_SITE_KEY', Rails.application.credentials.dig(:recaptcha, :site_key))
  config.secret_key = ENV.fetch('RECAPTCHA_SECRET_KEY', Rails.application.credentials.dig(:recaptcha, :secret_key))
  config.proxy = ENV.fetch('RECAPTCHA_PROXY', '')
end
