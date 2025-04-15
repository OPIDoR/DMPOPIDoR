# frozen_string_literal: true

module Mutations
  # CreateResearchOutput
  class CreateResearchOutput < BaseMutation
    argument :plan_id, Int, required: true
    argument :research_outputs, GraphQL::Types::JSON, required: true
    argument :format, String, default_value: 'dmp', required: false

    field :result, Types::MutationResponseType

    def resolve(plan_id:, research_outputs:, format:)
      plan = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve.find(plan_id)

      begin
        if format.eql?('rda')
          research_outputs = Import::Converters::RdaToStandardConverter.convert_research_output(research_outputs, {
            ethical_issues_exist: 'no',
            ethical_issues_description: '',
            ethical_issues_report: ''
          })
        end
        Import::PlanImportService.handle_research_outputs(plan, research_outputs)
      rescue => e
          raise GraphQL::ExecutionError, e.message
      end

      {
        result: {
          code: 200,
          message: "Research output#{research_outputs.length > 1 ? "s" : ""} created successfully for plan #{plan_id}.",
          success: true
        }
      }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Plan not found or access denied for the current user."
    end
  end
end
