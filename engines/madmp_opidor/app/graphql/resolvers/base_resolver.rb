# frozen_string_literal: true

require 'arel'

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    def self.apply(scope, filter, dmp_id)
      apply_filters(scope, filter, dmp_id)
    end

    def self.apply_and_conditions(scope, conditions, dmp_id)
      apply_conditions(scope, conditions, "and", dmp_id)
    end

    def self.apply_or_conditions(scope, conditions, dmp_id)
      apply_conditions(scope, conditions, "or", dmp_id)
    end

    private

    def self.build_condition(scope, filter)
      return nil unless filter[:className] && filter[:field] && filter[:value]

      apply_single_filter(scope, filter)
    end

    def self.apply_filters(scope, filter, dmp_id)
      return scope if filter.nil?

      if filter[:and].blank? && filter[:or].blank? && filter[:not].blank?
        raise GraphQL::ExecutionError, "The filter must contain at least one 'and', 'or' condition."
      end

      scope = apply_and_conditions(scope, filter[:and], dmp_id) if filter[:and].present?
      scope = apply_or_conditions(scope, filter[:or], dmp_id) if filter[:or].present?
      # scope = apply_not_conditions(scope, filter[:not], dmp_id) if filter[:not].present?

      scope
    end

    def self.apply_conditions(scope, conditions, operator = "and", dmp_id)
      conditions.each_with_index do |condition, index|
        unless condition[:className].present?
          raise GraphQL::ExecutionError, "Condition at index #{index} is missing 'className'."
        end
        unless condition[:field].present?
          raise GraphQL::ExecutionError, "Condition at index #{index} is missing 'field'."
        end
        if condition[:value].nil?
          raise GraphQL::ExecutionError, "Condition at index #{index} is missing 'value'."
        end
      end

      grouped_conditions = conditions.group_by { |condition| condition[:className] }

      joins = []
      operator_conditions = []

      primary_alias = Arel::Table.new(scope.table_name).alias("m1")

      operator_conditions << primary_alias[:dmp_id].eq(dmp_id)

      scope = MadmpFragment.from("#{scope.table_name} m1").select("DISTINCT m1.dmp_id")

      grouped_conditions.each_with_index do |(class_name, sub_filters), index|
        table_alias = index.zero? ? primary_alias : Arel::Table.new(scope.table_name).alias("m#{index + 1}")

        class_conditions = sub_filters.map do |sub_filter|
          build_condition(table_alias, sub_filter)
        end.compact

        operator_conditions << class_conditions.reduce(operator.to_sym) if class_conditions.any?

        if index > 0
          join_condition = primary_alias[:dmp_id].eq(table_alias[:dmp_id])
          joins << "JOIN #{scope.table_name} #{table_alias.name} ON #{join_condition.to_sql}"
        end
      end

      return scope.none unless operator_conditions.any?

      scope = scope.joins(joins.join(" "))
      scope = scope.where(operator_conditions.reduce(&:and))

      scope
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def self.apply_single_filter(scope, filter)
      class_name = filter[:className].downcase

      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || 'eq'

      table_alias = scope.is_a?(Arel::Table) ? "m1" : scope.name
      field_column = Arel.sql("LOWER(#{table_alias}.data->>'#{field}')")
      class_column = Arel.sql("#{table_alias}.classname")

      condition = nil

      case operator
      when 'eq'
        condition = class_column.eq(class_name).and(field_column.eq(value.downcase))
      when 'neq'
        condition = class_column.eq(class_name).and(field_column.not_eq(value.downcase))
      when 'like'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(#{table_alias}.data->>'#{field}') LIKE '%#{value.downcase}%'"))
      when 'regex'
        regex = value.gsub(%r{\A/|/\z}, '')
        condition = Arel::Nodes::SqlLiteral.new("LOWER(#{table_alias}.data->>'#{field}') ~* '#{regex}'")
        condition = class_column.eq(class_name).and(condition)
      when 'lt'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(#{table_alias}.data->>'#{field}') < '#{value}'"))
      when 'lte'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(#{table_alias}.data->>'#{field}') <= '#{value}'"))
      when 'gt'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(#{table_alias}.data->>'#{field}') > '#{value}'"))
      when 'gte'
        condition = class_column.eq(class_name).and(Arel.sql("LOWER(#{table_alias}.data->>'#{field}') >= '#{value}'"))
      else
        Rails.logger.warn "Unknown operator: #{operator}"
      end

      condition
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
  end
end
