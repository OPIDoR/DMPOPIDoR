# frozen_string_literal: true

module Mutations
  # Authenticate
  class CreateResearchOutput < BaseMutation
    argument :plan_id, Int, required: true
    argument :research_outputs, GraphQL::Types::JSON, required: true

    field :result, Types::MutationResponseType

    def resolve(plan_id:, research_outputs:)
      plan = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve.find(plan_id)

      begin
        Import::PlanImportService.handle_research_outputs(plan, research_outputs)
      rescue => e
          raise GraphQL::ExecutionError, e.message
      end

      {
        result: {
          code: 200,
          message: "Research output created successfully.",
          success: true
        }
      }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Plan not found or access denied for the current user."
    end
  end
end
