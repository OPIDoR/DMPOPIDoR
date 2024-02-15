# frozen_string_literal: true

ApiPagination.configure do |config|
  # If you have more than one gem included, you can choose a paginator.
  config.paginator = ENV.fetch('PAGINATOR', :kaminari)&.to_sym # or :will_paginate

  # By default, this is set to 'Total'
  config.total_header = ENV.fetch('PAGINATION_TOTAL_HEADER', 'X-Total')

  # By default, this is set to 'Per-Page'
  config.per_page_header = ENV.fetch('PAGINATION_PER_PAGE_HEADER', 'X-Per-Page')

  # Optional: set this to add a header with the current page number.
  config.page_header = ENV.fetch('PAGINATION_PAGE_HEADER', 'X-Page')

  # Optional: set this to add other response format. Useful with tools that define :jsonapi format
  config.response_formats = [ENV.fetch('PAGINATION_RESPONSE_FORMATS', :json)&.to_sym]

  # Optional: what parameter should be used to set the page option
  config.page_param = ENV.fetch('PAGINATION_PAGE_PARAM', :page)&.to_sym

  # Optional: what parameter should be used to set the per page option
  config.per_page_param = ENV.fetch('PAGINATION_PER_PAGE_PARAM', :per_page)&.to_sym

  # Optional: Include the total and last_page link header
  # By default, this is set to true
  # Note: When using kaminari, this prevents the count call to the database
  config.include_total = ENV.fetch('PAGINATION_INCLUDE_TOTAL', true).to_s.casecmp('true').zero?
end
