# frozen_string_literal: true

require 'json'

module Mutations
  # CreatePlan
  class CreatePlan < BaseMutation
    argument :plan, GraphQL::Types::JSON, required: true
    argument :template_id, Int, default_value: '4', required: true
    argument :format, String, default_value: 'standard', required: false

    field :result, Types::MutationResponseType

    def resolve(plan:, template_id:, format:)
      result = Import::PlanImporter.call({
                                           template_id: template_id,
                                           json_file: plan,
                                           format: format
                                         }, context[:current_user])

      unless result.success?
        raise GraphQL::ExecutionError, result.errors.join(', ')
      end

      {
        result: {
          code: 200,
          message: "Plan created successfully.",
          success: true
        }
      }
    end
  end
end
