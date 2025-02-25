# frozen_string_literal: true

require 'arel'

module Resolvers
  # FiltersResolver
  class PlansFiltersResolver < Resolvers::BaseResolver

    def self.apply_and_conditions(scope, conditions)
      grouped_conditions = conditions.group_by { |condition| condition[:className] }

      and_conditions = grouped_conditions.map do |class_name, sub_filters|
        and_conditions = sub_filters.map { |sub_filter| self.build_condition(scope, sub_filter) }
        and_conditions.reduce(&:and)
      end

      return scope.none unless and_conditions.any?

      scope = scope.where(and_conditions.reduce(&:or))
                   .select(:dmp_id)
                   .group(:dmp_id)
                   .having(Arel.sql("COUNT(*) = #{grouped_conditions.length}"))

      scope
    end

    def self.apply_or_conditions(scope, conditions)
      grouped_conditions = conditions.group_by { |condition| condition[:className] }

      or_conditions = grouped_conditions.map do |class_name, sub_filters|
        or_conditions = sub_filters.map { |sub_filter| self.build_condition(scope, sub_filter) }
        or_conditions.reduce(&:or)
      end

      return scope.none unless or_conditions.any?

      scope = scope.where(or_conditions.reduce(&:or))
                   .select(:dmp_id)
                   .group(:dmp_id)

      scope
    end
  end
end

