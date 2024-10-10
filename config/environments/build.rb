# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.eager_load = ENV.fetch('EAGER_LOAD', false).to_s.casecmp('true').zero?
end
