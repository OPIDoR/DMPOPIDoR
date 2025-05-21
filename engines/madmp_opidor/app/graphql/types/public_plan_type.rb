# frozen_string_literal: true

module Types
  # PublicPlanType
  class PublicPlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    field :template_name, String, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true

    def researchOutput
      object["researchOutput"].map do |ro|
        research_output = ResearchOutput.find(ro["research_output_id"])
        research_output_fragment = research_output.json_fragment
        additional_info = research_output_fragment.additional_info.except('moduleId', 'property_name')
        research_output_fragment.get_full_fragment.merge(configuration: additional_info)
      end
    end
  end
end
