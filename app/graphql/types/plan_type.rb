# frozen_string_literal: true

require 'jsonpath'
require 'json'

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    # field :templateName, String, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true do
      description 'Fetch research outputs'
      argument :filter, -> { Types::LogicalFilterInput }, required: false, description: 'A nested filter to allow complex filtering conditions.'
      argument :with_query, GraphQL::Types::Boolean, required: false, default_value: false
    end

    def researchOutput(filter:, with_query: false)
      return object['researchOutput'] unless filter.present?

      if with_query
        Rails.logger.info('[GraphQL API] ================')
        Rails.logger.info('[GraphQL API] Retrieving research output from database')
        Rails.logger.info('[GraphQL API] ================')
        plan_id = object['plan_id']

        subquery = JsonPlan
                     .select("jsonb_array_elements(data->'researchOutput') AS research_output")
                     .where(plan_id: plan_id)

        return JsonPlan
          .from(subquery)
          .select('jsonb_agg(research_output) as research_output_data')
          .yield_self { |rel| filter.present? ? rel.where(*build_jsonb_filters(filter)) : rel }
          .map { |research_output_data| research_output_data['research_output_data'] }
          .first || []
      end

      JsonPath.new("$..researchOutput[?(#{build_filter(filter)})]").on(object)
    end

    def build_filter(filter)
      return nil unless filter.present?

      and_cond = build_json_condition(filter[:and], '&&')
      or_cond = build_json_condition(filter[:or], '||')

      combined = [and_cond, or_cond].compact
      combined.join(" || ") unless combined.empty?
    end

    def build_json_condition(conditions, operator)
      return nil unless conditions.present?

      operators = {
        "eq"   => "==",
        "neq"  => "!=",
        "gt"   => ">",
        "lt"   => "<",
        "gte"  => ">=",
        "lte"  => "<="
      }

      conditions.map { |condition|
        field = condition[:field].sub(/^\$\.*\.?/, '').split('.').join("']['")
        value = condition[:value]
        op_condition = operators[condition[:operator]]

        "@['#{field}'] #{op_condition} #{value}"
      }.join(" #{operator} ")
    end

    def build_jsonb_filters(filter)
      return nil unless filter.present?

      and_sql = build_conditions(filter[:and], "AND")
      or_sql  = build_conditions(filter[:or],  "OR")

      combined = [and_sql, or_sql].compact
      ["(#{combined.join(" OR ")})"] unless combined.empty?
    end

    def build_conditions(conditions, operator)
      return nil unless conditions.present?

      conditions.map { |c|
        jsonb_path_where(path: c[:field], value: c[:value], operator: c[:operator] || "eq")
      }.join(" #{operator} ")
    end

    def jsonb_path_where(path:, value:, operator: "eq")
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

      op = operator_map[operator] || raise("Unsupported operator #{operator}")

      "jsonb_path_exists(research_output, '#{path} ? (@ #{op} #{value.inspect})')"
    end
  end
end
