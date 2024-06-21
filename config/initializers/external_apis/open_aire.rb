# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Open Aire Research Project Registry API. For more information about
# the API and to verify that your configuration settings are correct.
Rails.configuration.x.open_aire.api_base_url = ENV.fetch('OPEN_AIRE_API_BASE_URL', 'https://api.openaire.eu/')
# The api_url should contain `%s. This is where the funder is appended!
Rails.configuration.x.open_aire.search_path = ENV.fetch('OPEN_AIRE_SEARCH_PATH', 'projects/dspace/%s/ALL/ALL')
Rails.configuration.x.open_aire.default_funder = ENV.fetch('OPEN_AIRE_DEFAULT_FUNDER', 'H2020')
Rails.configuration.x.open_aire.active = ENV.fetch('OPEN_AIRE_ACTIVE', true).to_s.casecmp('true').zero?
