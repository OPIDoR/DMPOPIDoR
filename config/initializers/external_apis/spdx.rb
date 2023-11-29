# frozen_string_literal: true

# These configuration settings are used to communicate with the SPDX License repository.
# Licenses are loaded via a Rake task and stored in the local :licenses DB table.
# Please refer to: http://spdx.org/licenses/
Rails.configuration.x.spdx.landing_page_url = ENV.fetch('SPDX_LANDING_PAGE_URL', 'http://spdx.org/licenses/')
Rails.configuration.x.spdx.api_base_url = ENV.fetch('SPDX_API_BASE_URL', 'https://raw.githubusercontent.com/spdx/license-list-data/')
Rails.configuration.x.spdx.list_path = ENV.fetch('SPDX_LIST_PATH', 'master/json/licenses.json')
Rails.configuration.x.spdx.active = ENV.fetch('SPDX_ACTIVE', true).to_s.casecmp('true').zero?
