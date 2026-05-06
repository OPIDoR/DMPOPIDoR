# frozen_string_literal: true

module Resolvers
  # ResearchOutputsResolver is responsible for resolving the research outputs
  # associated with a plan, applying optional filters to refine the results.
  class ResearchOutputsResolver < GraphQL::Schema::Resolver
    type GraphQL::Types::JSON, null: true
    argument :filter, Types::LogicalFilterInput, required: false

    def resolve(filter: nil)
      return object['researchOutput'] || [] unless filter.present?

      plan_id = object['plan_id']

      subquery = JsonPlan
                 .select("jsonb_array_elements(data->'researchOutput') AS research_output")
                 .where(plan_id: plan_id)

      scope = JsonPlan
              .from(subquery)
              .select('jsonb_agg(research_output) AS research_output_data')

      sql = Resolvers::JsonbResolver.build_jsonb_filters(filter, field: 'research_output')
      scope = scope.where(sql) if sql.present?

      scope
        .map { |r| r['research_output_data'] }
        .first || []
    end
  end
end
