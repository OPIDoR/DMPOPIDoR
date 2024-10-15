# frozen_string_literal: true

# Credentials for RDA Metadata Standards Catalog (RDAMSC)
# To disable this feature, simply set 'active' to false
Rails.configuration.x.rdamsc.landing_page_url = ENV.fetch('RDAMSC_LANDING_PAGE_URL', 'http://rdamsc.bath.ac.uk')
Rails.configuration.x.rdamsc.api_base_url = ENV.fetch('RDAMSC_API_BASE_URL', 'https://rdamsc.bath.ac.uk/')
Rails.configuration.x.rdamsc.schemes_path = ENV.fetch('RDAMSC_SCEHEMES_PATH', 'api2/m')
Rails.configuration.x.rdamsc.thesaurus_path = ENV.fetch('RDAMSC_THESAURUS_PATH', 'api2/thesaurus/concepts')
Rails.configuration.x.rdamsc.active = ENV.fetch('RDAMSC_ACTIVE', true).to_s.casecmp('true').zero?