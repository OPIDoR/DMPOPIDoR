# frozen_string_literal: true

module Mutations
  # UpdateResearchOutput
  class UpdateResearchOutput < BaseMutation
    argument :id, Int, required: true
    argument :data, GraphQL::Types::JSON, required: true

    field :result, Types::MutationResponseType

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def resolve(id:, data:)
      research_output = ResearchOutput.find(id)

      Api::V1::PlansPolicy::Scope.new(context[:current_user], plan).resolve

      raise GraphQL::ExecutionError, 'You are not allowed to update research output' unless ResearchOutputPolicy.new(
        context[:current_user], research_output
      ).update?

      research_output_description = research_output.json_fragment.research_output_description

      I18n.with_locale research_output.plan.template.locale do
        research_output_description.raw_import(data['researchOutputDescription'],
                                               research_output_description.madmp_schema)
        research_output_description.update_research_output_parameters(skip_broadcast: true)
        research_output.update!({
                                  title: data['researchOutputDescription']['title'],
                                  abbreviation: data['researchOutputDescription']['shortName']
                                })
      end

      {
        result: {
          code: 200,
          message: "Research output [#{id}] updated successfully for plan [#{research_output.plan_id}].",
          success: true
        }
      }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, 'Plan not found or access denied for the current user.'
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
  end
end
