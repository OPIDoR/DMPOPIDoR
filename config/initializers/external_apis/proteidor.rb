# frozen_string_literal: true

Rails.configuration.x.proteidor.api_base_url = ENV.fetch('PROTEIDOR_API_BASE_URL', 'http://proteidor_api:50000/api/')
Rails.configuration.x.proteidor.formats_path = ENV.fetch('PROTEIDOR_FORMATS_PATH', 'export/formats')
Rails.configuration.x.proteidor.export_path = ENV.fetch('PROTEIDOR_EXPORT_PATH', 'export')
Rails.configuration.x.proteidor.active = ENV.fetch('PROTEIDOR_ACTIVE', true).to_s.casecmp('true').zero?
