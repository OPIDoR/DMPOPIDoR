# frozen_string_literal: true

module Mutations
  # CreateResearchOutput
  class CreatePlan < BaseMutation
    argument :locale, Types::LocaleEnum, default_value: 'FR', required: true
    argument :format, Types::FormatEnum, default_value: 'STANDARD', required: true
    argument :context, Types::ContextEnum, default_value: 'RESEARCH_PROJECT', required: true, as: :context_param
    argument :data, GraphQL::Types::JSON, required: true

    field :result, Types::MutationResponseType

    def resolve(locale:, format:, context_param:, data:)
      raise GraphQL::ExecutionError, _('You are not allowed to create plan') unless Api::V0::PlansPolicy.new(
        context[:current_user], Plan
      ).create?

      begin
        new_plan = Plan.new
        plan_importer = Import::Plan.new

        file = Tempfile.new(['plan', '.json'])
        file.write(data.to_json)
        file.rewind

        res = plan_importer.import(new_plan, {
                                     locale: locale.downcase,
                                     format: format.downcase,
                                     context: context_param.downcase,
                                     json_file: file
                                   }, Api::V1::Madmp::PlansController.new.determine_owner(client: context[:current_user], dmp: JSON.parse(data.to_json)))

        {
          result: {
            code: 200,
            message: _("Plan [#{res[:planId]}] created successfully."),
            success: true
          }
        }
      rescue StandardError => e
        raise GraphQL::ExecutionError, e.message
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
