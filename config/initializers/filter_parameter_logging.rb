# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
# Rails.application.config.filter_parameters += [
#     :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn
#   ]
Rails.application.config.filter_parameters += [ENV.fetch('APPLICATION_FILTER_PARAMETERS', :password)&.to_sym]
