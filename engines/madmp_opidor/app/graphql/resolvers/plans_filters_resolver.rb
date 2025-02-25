# frozen_string_literal: true

require 'arel'

module Resolvers
  # FiltersResolver
  class PlansFiltersResolver < Resolvers::BaseResolver

    def self.apply_and_conditions(scope, conditions)
      grouped_conditions = conditions.group_by { |condition| condition[:className] }

      super(scope, conditions)
        .select(:dmp_id)
         .group(:dmp_id)
         .having(Arel.sql("COUNT(*) = #{grouped_conditions.length}"))
    end

    def self.apply_or_conditions(scope, conditions)
      super(scope, conditions)
           .select(:dmp_id)
           .group(:dmp_id)
    end
  end
end

