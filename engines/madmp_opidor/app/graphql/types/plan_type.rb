# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, Types::MetaType, null: true
    field :project, Types::ProjectType, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true do
      argument :filter, Types::LogicalFilterInput, required: false
      description 'Fetch research outputs'
    end

    def researchOutput(filter: nil)
      dmp_id = object["id"]

      research_outputs = MadmpFragment.where(classname: 'research_output', dmp_id:)

      research_outputs.flat_map do |research_output|
        Resolvers::ResearchOutputsFiltersResolver.apply(research_output.dmp_fragments, filter)&.map do |madmp_fragment|
          madmp_fragment.get_full_fragment(with_ids: true)
        end
      end.compact.uniq { |fragment| fragment['id'] } # rubocop:disable Style/MultilineBlockChain
    end
  end
end
