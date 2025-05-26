# frozen_string_literal: true

namespace :external_api do
  desc 'Fetch the latest RDA Metadata Standards'
  task load_rdamsc_standards: :environment do
    p 'Fetching the latest RDAMSC metadata standards and updating the metadata_standards table'
    ExternalApis::RdamscService.fetch_metadata_standards
  end

  desc 'Load Repositories from re3data'
  task load_re3data_repos: :environment do
    p 'Fetching the latest re3data repository metadata and updating the repositories table'
    p 'This can take in excess of 10 minutes to complete ...'
    ExternalApis::Re3dataService.fetch
  end
end
