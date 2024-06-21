# frozen_string_literal: true

Rails.configuration.x.loterre.landing_page_url = ENV.fetch('LOTERRE_LANDING_PAGE_URL', 'https://www.loterre.fr/')
Rails.configuration.x.loterre.api_base_url = ENV.fetch('LOTERRE_API_BASE_URL', 'https://skosmos.loterre.fr/rest/v1')
Rails.configuration.x.loterre.active = ENV.fetch('LOTERRE_ENABLED', true).to_s.casecmp('true').zero?
