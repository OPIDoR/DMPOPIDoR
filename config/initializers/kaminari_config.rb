# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = ENV.fetch('KAMINARI_DEFAULT_PER_PAGE', Rails.configuration.x.results_per_page)
  # config.max_per_page = nil
  # config.window = 4
  # config.outer_window = 0
  # config.left = 0
  # config.right = 0
  # config.page_method_name = :page
  # config.param_name = :page
  config.params_on_first_page = ENV.fetch('KAMINARI_PARAMS_ON_FIRST_PAGE', true).to_s.casecmp('true').zero?
end
