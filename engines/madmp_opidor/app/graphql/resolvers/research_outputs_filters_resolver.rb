# frozen_string_literal: true

require 'arel'

module Resolvers
  # FiltersResolver
  class ResearchOutputsFiltersResolver < Resolvers::BaseResolver
    def self.apply_and_conditions(scope, conditions)
      super(scope, conditions)
        .select('*')
    end

    def self.apply_or_conditions(scope, conditions)
      super(scope, conditions)
        .select('*')
    end
  end
end
