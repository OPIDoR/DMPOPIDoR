# frozen_string_literal: true

# These configuration settings are used to communicate with the
# MADMP Codebase Service
Rails.configuration.x.madmp_codebase.api_base_url = ENV.fetch('MADMP_CODEBASE_API_BASE_URL', 'http://codebase_api:50000/')
Rails.configuration.x.madmp_codebase.scripts_path = ENV.fetch('MADMP_CODEBASE_SCRIPTS_PATH', 'scripts')
Rails.configuration.x.madmp_codebase.run_path = ENV.fetch('MADMP_CODEBASE_RUN_PATH', 'scripts/run')
Rails.configuration.x.madmp_codebase.active = ENV.fetch('MADMP_CODEBASE_ACTIVE', true).to_s.casecmp('true').zero?
