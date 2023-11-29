# frozen_string_literal: true

# These configuration settings are used to communicate with the
# Research Organization Registry (ROR) API. For more information about
# the API and to verify that your configuration settings are correct,
# please refer to: https://github.com/ror-community/ror-api
Rails.configuration.x.ror.landing_page_url = ENV.fetch('ROR_LANDING_PAGE_URL', 'https://ror.org/')
Rails.configuration.x.ror.api_base_url = ENV.fetch('ROR_API_BASE_URL', 'https://api.ror.org/')
Rails.configuration.x.ror.heartbeat_path = ENV.fetch('ROR_HEARTBEAT_PATH', 'heartbeat')
Rails.configuration.x.ror.search_path = ENV.fetch('ROR_SEARCH_PATH', 'organizations')
Rails.configuration.x.ror.max_pages = ENV.fetch('ROR_MAX_PAGES', 2)&.to_i
Rails.configuration.x.ror.max_results_per_page = ENV.fetch('ROR_RESULTS_PER_PAGE', 20)&.to_i
Rails.configuration.x.ror.max_redirects = ENV.fetch('ROR_MAX_REDIRECTS', 3)&.to_i
Rails.configuration.x.ror.active = ENV.fetch('ROR_ACTIVE', true).to_s.casecmp('true').zero?
