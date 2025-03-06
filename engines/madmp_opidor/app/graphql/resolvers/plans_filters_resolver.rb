# frozen_string_literal: true

require 'arel'

module Resolvers
  # FiltersResolver
  class PlansFiltersResolver < Resolvers::BaseResolver

    def self.apply_and_conditions(scope, conditions, dmp_id)
      super(scope, conditions, dmp_id)
    end

    def self.apply_or_conditions(scope, conditions, dmp_id)
      super(scope, conditions, dmp_id)
    end
  end
end

