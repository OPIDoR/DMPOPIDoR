
# frozen_string_literal: true

module Resolvers
  class JsonbResolver < GraphQL::Schema::Resolver
    def self.build_jsonb_filters(filter, field: "data")
      return nil unless filter.present?

      and_sql = build_conditions(filter[:and], operator: "AND", field:)
      or_sql  = build_conditions(filter[:or],  operator: "OR", field:)

      combined = [and_sql, or_sql].compact
      ["(#{combined.join(" OR ")})"] unless combined.empty?
    end

    def self.build_conditions(conditions, operator:, field:)
      return nil unless conditions.present?

      conditions.map { |c|
        jsonb_path_where(path: c[:field], value: c[:value], operator: c[:operator] || "eq", field: field)
      }.join(" #{operator} ")
    end

    def self.jsonb_path_where(path:, value:, operator: "eq", field:)
      operator_map = {
        "eq"   => "==",
        "neq"  => "!=",
        "like" => "like_regex",
        "regex" => "like_regex",
        "gt"   => ">",
        "lt"   => "<",
        "gte"  => ">=",
        "lte"  => "<=",
      }

      if operator == 'in'
        raise "Value for IN must be an array" unless value.is_a?(Array)

        conditions = value.map { |v| "@ == #{v.inspect}" }.join(" || ")
        return "jsonb_path_exists(#{field}, '#{path} ? (#{conditions})')"
      end

      op = operator_map[operator] || raise("Unsupported operator #{operator}")

      "jsonb_path_exists(#{field}, '#{path} ? (@ #{op} #{value.inspect})')"
    end
  end
end
