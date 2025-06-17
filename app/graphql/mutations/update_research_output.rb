# frozen_string_literal: true

module Mutations
  # UpdateResearchOutput
  class UpdateResearchOutput < BaseMutation
    argument :id, Int, required: true
    argument :data, GraphQL::Types::JSON, required: true

    field :result, Types::MutationResponseType

    def resolve(id:, data:)
      research_output = ResearchOutput.find(params[:id])
      plan =  research_output.plan

      plan = Api::V1::PlansPolicy::Scope.new(context[:current_user], plan).resolve

      raise GraphQL::ExecutionError, 'You are not allowed to update research output' unless ResearchOutputPolicy.new(context[:current_user], ResearchOutput.new(plan_id: plan.id)).update?

      research_output_description = research_output.json_fragment.research_output_description

      I18n.with_locale plan.template.locale do
        updated_data = research_output_description.data.merge({
                                                                title: data[:title],
                                                                shortName: data[:abbreviation],
                                                                type: data[:type],
                                                                containsPersonalData: data[:configuration][:hasPersonalData] ? _('Yes') : _('No') # rubocop:disable Layout/LineLength
                                                              })
        research_output_description.update(data: updated_data)
        research_output_description.update_research_output_parameters(skip_broadcast: true)
        research_output.update!(data)
      end

      {
        result: {
          code: 200,
          message: "Research output [#{id}} updated successfully for plan [#{plan.id}].",
          success: true
        }
      }
    rescue ActiveRecord::RecordNotFound
      raise GraphQL::ExecutionError, "Plan not found or access denied for the current user."
    end
  end
end
