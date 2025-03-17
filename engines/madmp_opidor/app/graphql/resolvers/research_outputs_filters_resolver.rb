# frozen_string_literal: true

require 'arel'

module Resolvers
  # FiltersResolver
  class ResearchOutputsFiltersResolver < Resolvers::BaseResolver
    def self.apply_filter_conditions(scope, conditions, dmp_id)
      super(scope, conditions, dmp_id)
        .select("*")
    end
  end
end
