# frozen_string_literal: true

Rails.configuration.x.orcid.landing_page_url = ENV.fetch('ORCID_LANDIG_PAGE_URL', 'https://orcid.org/')
Rails.configuration.x.orcid.api_base_url = ENV.fetch('ORCID_API_BASE_URL', 'https://pub.orcid.org/v3.0/')
Rails.configuration.x.orcid.search_path = 'expanded-search'
Rails.configuration.x.orcid.active = ENV.fetch('ORCID_ACTIVE', true).to_s.casecmp('true').zero?
Rails.configuration.x.orcid.default_rows = ENV.fetch('ORCID_DEFAULT_ROWS', 1000)&.to_i
