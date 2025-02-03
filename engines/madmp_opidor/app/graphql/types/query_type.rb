# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    field :fragments, resolver: Resolvers::FragmentsResolver, description: 'Fetch fragments'
    # field :researchOutputs, resolver: Resolvers::ResearchOutputsResolver, description: "Fetch research outputs"

    field :plans, [PlanType], null: false do
      argument :filter, Types::LogicalFilterInput, required: false
      argument :size, Integer, required: false, default_value: 10, description: 'Number of items to fetch'
      argument :offset, Integer, required: false, default_value: 0, description: 'Offset for pagination'
      description 'Fetch plans with optional filtering'
    end

    def plans(filter: nil, size: 10, offset: 0)
      scope = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      fragments_by_plan_id = MadmpFragment.where("(data->>'plan_id')::int IN (?)", scope&.map(&:id))
      fragments_by_plan_id.flat_map do |fragment|
        Resolvers::FiltersResolver.apply(fragment.dmp_fragments, filter, size, offset)&.map do |madmp_fragment|
          madmp_fragment.dmp.get_full_fragment
        end
      end.compact.uniq { |fragment| fragment[:plan_id] } # rubocop:disable Style/MultilineBlockChain
    end
  end
end
