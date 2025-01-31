require 'arel'

module Resolvers
  class FiltersResolver
    def self.apply(scope, filter, size, offset)
      filtered_scope = apply_filters(scope, filter)

      # filtered_scope = filtered_scope.offset(offset).limit(size) if size && offset

      filtered_scope
    end

    def self.apply_filters(scope, filter)
      return scope if filter.nil?

      scope = apply_and_conditions(scope, filter[:and]) if filter[:and].present?
      scope = apply_or_conditions(scope, filter[:or]) if filter[:or].present?
      scope = apply_not_conditions(scope, filter[:not]) if filter[:not].present?

      scope
    end

    def self.apply_and_conditions(scope, conditions)
      and_conditions = conditions.map { |sub_filter| build_condition(scope, sub_filter) }.compact

      if and_conditions.any?
        scope = scope.where(and_conditions.reduce(&:or))
        scope = scope
                  .select('madmp_fragments.dmp_id', 'MAX(madmp_fragments.id) as id')
                  .group(:dmp_id)
                  .having(Arel.sql("COUNT(*) = #{conditions.length}"))
      else
        return scope.none
      end
      scope
    end

    def self.apply_or_conditions(scope, conditions)
      or_conditions = conditions.map { |sub_filter| build_condition(scope, sub_filter) }.compact

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

    def self.apply_single_filter(scope, filter)
      class_name = filter[:className]
      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || "eq"

      table = scope.arel_table
      field_column = Arel.sql("data->>'#{field}'")
      class_column = table[:classname]

      condition = nil

      case operator
      when "eq"
        condition = class_column.eq(class_name).and(field_column.eq(value))
      when "neq"
        condition = class_column.eq(class_name).and(field_column.not_eq(value))
      when "like"
        condition = class_column.eq(class_name).and(field_column.like("%#{value.downcase}%"))
      when "regex"
        regex = value.gsub(/\A\/|\/\z/, '')
        condition = Arel::Nodes::SqlLiteral.new("LOWER(data->>'#{field}') ~* '#{regex}'")
        condition = class_column.eq(class_name).and(condition)
      else
        Rails.logger.warn "Unknown operator: #{operator}"
      end

      condition
    end
  end
end
