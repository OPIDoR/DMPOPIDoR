# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    field :template_name, String, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true
    # field :researchOutput, GraphQL::Types::JSON, null: true do
    #  argument :filter, Types::LogicalFilterInput, required: false
    #  description 'Fetch research outputs'
    # end

    def researchOutput
      object["researchOutput"].map do |ro|
        research_output = ResearchOutput.find(ro["research_output_id"])
        research_output_fragment = research_output.json_fragment
        additional_info = research_output_fragment.additional_info.except('moduleId', 'property_name')
        research_output_fragment.get_full_fragment.merge(configuration: additional_info)
      end
    end

    #def researchOutput(filter: nil)
    # dmp_id = object["id"]

    # research_outputs = MadmpFragment.where(classname: 'research_output', dmp_id:)

    # return research_outputs.map { |research_output| research_output&.get_full_fragment(with_ids: true, with_template_name: true) } if filter.nil?

    # research_outputs.flat_map do |research_output|
    #    Resolvers::ResearchOutputsFiltersResolver.apply(research_output.children, filter)&.map do |madmp_fragment|
    #      madmp_fragment&.parent&.get_full_fragment(with_ids: true, with_template_name: true)
    #    end
    #  end.compact # rubocop:disable Style/MultilineBlockChain
    #end
  end
end
