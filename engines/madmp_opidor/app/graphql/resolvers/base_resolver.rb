# frozen_string_literal: true

require 'arel'

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    def self.apply(scope, filter, dmp_id)
      apply_filters(scope, filter, dmp_id)
    end

    private

    def self.build_condition(scope, filter)
      return nil unless filter[:className] && filter[:field] && filter[:value]

      apply_single_filter(scope, filter)
    end

    def self.apply_filters(scope, filter, dmp_id)
      return scope if filter.nil?

      if filter[:and].blank? && filter[:or].blank?
        raise GraphQL::ExecutionError, "The filter must contain at least one 'and', 'or' condition."
      end

      apply_conditions(scope, filter, dmp_id)
    end

    def self.apply_conditions(scope, conditions, dmp_id)
      and_operator_conditions = []
      or_operator_conditions = []

      sub_and_operator_conditions = []
      sub_or_operator_conditions = []

      primary_alias = Arel::Table.new(scope.table_name).alias("m1")
      and_operator_conditions << primary_alias[:dmp_id].eq(dmp_id)
      scope = MadmpFragment.from("#{scope.table_name} m1").select("DISTINCT m1.dmp_id")

      joins = []
      sub_joins = []

      conditions.keys.each do |operator|
        validate_conditions(conditions[operator], operator)

        grouped_conditions = conditions[operator].group_by { |condition| condition[:className] }

        grouped_conditions.each_with_index do |(class_name, sub_filters), index|
          table_alias = index.zero? && operator == :and ? primary_alias : Arel::Table.new(scope.table_name).alias("m_#{operator}_#{index + 1}")

          class_conditions = sub_filters.map do |sub_filter|
            if sub_filter[:and].present? || sub_filter[:or].present?

              sub_conditions = {
                and: sub_filter[:and],
                or: sub_filter[:or]
              }.compact

              sub_class_conditions = []

              sub_conditions.keys.each do |sub_operator|
                validate_conditions(sub_conditions[sub_operator], sub_operator)

                grouped_sub_conditions = sub_conditions[sub_operator].group_by { |condition| condition[:className] }

                grouped_sub_conditions.each_with_index do |(class_name, sub_filters), index|
                  sub_table_alias = Arel::Table.new(scope.table_name).alias("m_sub_#{sub_operator}_#{index + 1}")

                  sub_class_conditions = sub_filters.map do |sub_filter|
                    build_condition(sub_table_alias, sub_filter)
                  end

                  sub_class_conditions << table_alias[:dmp_id].eq(dmp_id) if sub_operator == :or

                  if sub_class_conditions.any?
                    (sub_operator == :and ? sub_and_operator_conditions : sub_or_operator_conditions) << sub_class_conditions.reduce(&:and)
                  end

                  class_name_downcased = class_name.downcase
                  sub_joins << "JOIN #{scope.table_name} #{sub_table_alias.name} ON (#{sub_table_alias.name}.classname = '#{class_name_downcased}' AND #{sub_table_alias.name}.id = (#{table_alias.name}.data->'#{class_name_downcased}'->>'dbid')::INTEGER)"
                end
              end
              sub_class_conditions.flatten
            else
              build_condition(table_alias, sub_filter)
            end
          end.compact.flatten

          class_conditions << table_alias[:dmp_id].eq(dmp_id) if operator == :or

          if class_conditions.any?
            (operator == :and ? and_operator_conditions : or_operator_conditions) << class_conditions.reduce(&:and)
          end

          if operator == :or || index.positive?
            join_condition = primary_alias[:dmp_id].eq(table_alias[:dmp_id])
            joins << "JOIN #{scope.table_name} #{table_alias.name} ON #{join_condition.to_sql}"
          end
        end
      end

      joins = joins.concat(sub_joins)
      and_operator_conditions = and_operator_conditions.concat(sub_and_operator_conditions)
      or_operator_conditions = or_operator_conditions.concat(sub_or_operator_conditions)

      final_and_conditions = and_operator_conditions.reduce(&:and)
      final_or_conditions = or_operator_conditions.reduce(&:or)

      if final_and_conditions && final_or_conditions
        final_operators = Arel::Nodes::Grouping.new(final_and_conditions).or(final_or_conditions)
      elsif final_and_conditions
        final_operators = final_and_conditions
      elsif final_or_conditions
        final_operators = final_or_conditions
      else
        return scope.none
      end

      scope = scope.joins(joins.join(" ")) unless joins.empty?
      scope = scope.where(final_operators)

      scope
    end

    def self.validate_conditions(conditions, operator)
      return if conditions.nil? || conditions.empty?

      conditions.each_with_index do |condition, index|
        unless condition[:className].present?
          raise GraphQL::ExecutionError, "Condition at index #{index} is missing 'className' in '#{operator}' filter."
        end
        unless condition[:field].present?
          raise GraphQL::ExecutionError, "Condition at index #{index} is missing 'field' in '#{operator}' filter."
        end
        if condition[:value].nil?
          raise GraphQL::ExecutionError, "Condition at index #{index} is missing 'value' in '#{operator}' filter."
        end
      end
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
