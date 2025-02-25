# frozen_string_literal: true

require 'arel'

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    def self.apply(scope, filter, _size = nil, _offset = nil)
      apply_filters(scope, filter)

      # filtered_scope = filtered_scope.offset(_offset).limit(_size) if _size && _offset
    end

    def self.apply_and_conditions(scope, conditions)
      apply_conditions(scope, conditions, "and")
    end

    def self.apply_or_conditions(scope, conditions)
      apply_conditions(scope, conditions, "or")
    end

    def self.build_condition(scope, filter)
      return nil unless filter[:className] && filter[:field] && filter[:value]

      apply_single_filter(scope, filter)
    end

    private

    def self.apply_filters(scope, filter)
      return scope if filter.nil?

      scope = apply_and_conditions(scope, filter[:and]) if filter[:and].present?
      scope = apply_or_conditions(scope, filter[:or]) if filter[:or].present?
      # scope = apply_not_conditions(scope, filter[:not]) if filter[:not].present?

      scope
    end

    def self.apply_conditions(scope, conditions, operator = "and")
      grouped_conditions = conditions.group_by { |condition| condition[:className] }

      operator_conditions = grouped_conditions.map do |class_name, sub_filters|
        operator_conditions = sub_filters.map { |sub_filter| self.build_condition(scope, sub_filter) }
        operator_conditions.reduce(operator.to_sym)
      end

      return scope.none unless operator_conditions.any?

      scope.where(operator_conditions.reduce(&:or))
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def self.apply_single_filter(scope, filter)
      class_name = filter[:className].downcase
      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || 'eq'

      table = scope.arel_table
      field_column = Arel.sql("LOWER(data->>'#{field}')")
      class_column = table[:classname]

      condition = nil

      case operator
      when 'eq'
        condition = class_column.eq(class_name).and(field_column.eq(value.downcase))
      when 'neq'
        condition = class_column.eq(class_name).and(field_column.not_eq(value.downcase))
      when 'like'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(data->>'#{field}') LIKE '%#{value.downcase}%'"))
      when 'regex'
        regex = value.gsub(%r{\A/|/\z}, '')
        condition = Arel::Nodes::SqlLiteral.new("LOWER(data->>'#{field}') ~* '#{regex}'")
        condition = class_column.eq(class_name).and(condition)
      when 'lt'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(data->>'#{field}') < '#{value}'"))
      when 'lte'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(data->>'#{field}') <= '#{value}'"))
      when 'gt'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(data->>'#{field}') > '#{value}'"))
      when 'gte'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(data->>'#{field}') >= '#{value}'"))
      else
        Rails.logger.warn "Unknown operator: #{operator}"
      end

      condition
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
  end
end
