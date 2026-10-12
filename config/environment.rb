# frozen_string_literal: true

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do
  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = Rails.configuration.x.rails_serve_static_files.present?
end

# Used by Rails' routes url_helpers (typically when including a link in an email)
Rails.application.routes.default_url_options[:host] = ENV.fetch('DMPROADMAP_HOST', 'dmpopidor')
