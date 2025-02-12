# frozen_string_literal: true

require 'arel'

module Resolvers
  # FiltersResolver
  class FiltersResolver
    def self.apply(scope, filter, _size, _offset)
      apply_filters(scope, filter)

      # filtered_scope = filtered_scope.offset(offset).limit(size) if size && offset
    end

    def self.apply_filters(scope, filter)
      return scope if filter.nil?

      scope = apply_and_conditions(scope, filter[:and]) if filter[:and].present?
      scope = apply_or_conditions(scope, filter[:or]) if filter[:or].present?
      scope = apply_not_conditions(scope, filter[:not]) if filter[:not].present?

      scope
    end

    def self.apply_and_conditions(scope, conditions)
      and_conditions = conditions.filter_map { |sub_filter| build_condition(scope, sub_filter) }

      return scope.none unless and_conditions.any?

      scope = scope.where(and_conditions.reduce(&:or))
      scope
        .select('madmp_fragments.dmp_id', 'MAX(madmp_fragments.id) as id')
        .group(:dmp_id)
        .having(Arel.sql("COUNT(*) = #{conditions.length}"))
    end

    def self.apply_or_conditions(scope, conditions)
      or_conditions = conditions.filter_map { |sub_filter| build_condition(scope, sub_filter) }

      if or_conditions.any?
        combined_scope = or_conditions.reduce do |accum, condition|
          accum.or(condition)
        end

        scope = scope.where(combined_scope)
        scope = scope
                .select('madmp_fragments.dmp_id', 'MAX(madmp_fragments.id) as id')
                .group(:dmp_id)
      else
        Rails.logger.warn "No valid OR conditions found: #{conditions.inspect}"
        return scope.none
      end

      scope
    end

    def self.build_condition(scope, filter)
      return nil unless filter[:className] && filter[:field] && filter[:value]

      apply_single_filter(scope, filter)
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def self.apply_single_filter(scope, filter)
      class_name = filter[:className]
      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || 'eq'

      table = scope.arel_table
      field_column = Arel.sql("data->>'#{field}'")
      class_column = table[:classname]

      condition = nil

      case operator
      when 'eq'
        condition = class_column.eq(class_name).and(field_column.eq(value))
      when 'neq'
        condition = class_column.eq(class_name).and(field_column.not_eq(value))
      when 'like'
        condition = class_column.eq(class_name).and(field_column.like("%#{value.downcase}%"))
      when 'regex'
        regex = value.gsub(%r{\A/|/\z}, '')
        condition = Arel::Nodes::SqlLiteral.new("LOWER(data->>'#{field}') ~* '#{regex}'")
        condition = class_column.eq(class_name).and(condition)
      when 'lt'
        condition = class_column.eq(class_name).and(Arel.sql("data->>'#{field}' < '#{value}'"))
      when 'lte'
        condition = class_column.eq(class_name).and(Arel.sql("data->>'#{field}' <= '#{value}'"))
      when 'gt'
        condition = class_column.eq(class_name).and(Arel.sql("data->>'#{field}' > '#{value}'"))
      when 'gte'
        condition = class_column.eq(class_name).and(Arel.sql("data->>'#{field}' >= '#{value}'"))
      else
        Rails.logger.warn "Unknown operator: #{operator}"
      end

      condition
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
  end
end
