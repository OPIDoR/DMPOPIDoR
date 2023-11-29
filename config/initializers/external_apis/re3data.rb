# frozen_string_literal: true

# Credentials for minting DOIs via re3data
# To disable this feature, simply set 'active' to false
Rails.configuration.x.re3data.landing_page_url = ENV.fetch('RE3DATA_LANDING_PAGE', 'https://www.re3data.org/')
Rails.configuration.x.re3data.api_base_url = ENV.fetch('RE3DATA_API_BASE_URL', 'https://www.re3data.org/api/v1/')
Rails.configuration.x.re3data.list_path = ENV.fetch('RE3DATA_LIST_PATH', 'repositories')
Rails.configuration.x.re3data.repository_path = ENV.fetch('RE3DATA_RESPOSITORY_PATH', 'repository/')
Rails.configuration.x.re3data.active = ENV.fetch('RE3DATA_ACTIVE', true).to_s.casecmp('true').zero?
