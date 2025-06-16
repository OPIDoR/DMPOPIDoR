# frozen_string_literal: true

module Mutations
  # UpdateResearchOutput
  class UpdateResearchOutput < BaseMutation
    argument :research_output_id, Int, required: true
    argument :research_output, GraphQL::Types::JSON, required: true

    field :result, Types::MutationResponseType

    def resolve(research_output_id:, research_output:)
      research_output = ResearchOutput.find(params[:id])
      plan =  research_output.plan

      plan = Api::V1::PlansPolicy::Scope.new(context[:current_user], plan).resolve

      raise GraphQL::ExecutionError, 'You are not allowed to create research output(s)' unless ResearchOutputPolicy.new(context[:current_user], ResearchOutput.new(plan_id: plan.id)).create?

      {
        result: {
          code: 200,
          message: "Research output [#{research_output_id}} updated successfully for plan [#{plan_id}].",
          success: true
        }
      }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Plan not found or access denied for the current user."
    end
  end
end
