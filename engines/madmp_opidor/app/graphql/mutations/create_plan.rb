# frozen_string_literal: true

module Mutations
  # CreateResearchOutput
  class CreatePlan < BaseMutation
    argument :template_id, Int, required: true
    argument :format, String, default_value: 'standard', required: false
    argument :plan, GraphQL::Types::JSON, required: true

    field :result, Types::MutationResponseType

    def resolve(template_id:, format:, plan:)
      raise GraphQL::ExecutionError, _('You are not allowed to create plan') unless Api::V0::PlansPolicy.new(context[:current_user], Plan).create?

      begin
        new_plan = ::Plan.new
        plan_importer = Import::Plan.new

        file = Tempfile.new(['plan', '.json'])
        file.write(plan.to_json)
        file.rewind

        res = plan_importer.import(new_plan, {
          template_id: template_id,
          format: format,
          json_file: file,
        }, context[:current_user])

        {
          result: {
            code: 200,
            message: _("Plan [#{res[:planId]}] created successfully."),
            success: true
          }
        }
      rescue StandardError => errs
        raise GraphQL::ExecutionError, errs.message
      rescue IOError
        raise GraphQL::ExecutionError, _('Unvalid file')
      rescue JSON::ParserError
        raise GraphQL::ExecutionError, _('File should contain JSON')
      rescue StandardError => e
        raise GraphQL::ExecutionError, "#{_('An error has occured: ')} #{e.message}"
      end
    end
  end
end
