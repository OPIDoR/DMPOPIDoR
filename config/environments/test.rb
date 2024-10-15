# frozen_string_literal: true

require 'active_support/core_ext/integer/time'
require 'json'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.public_file_server.headers = { 'Cache-Control' => "public, max-age=#{1.hour.to_i}" }
end
