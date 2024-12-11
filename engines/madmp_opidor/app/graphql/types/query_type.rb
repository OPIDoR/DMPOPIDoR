module Types
  class QueryType < Types::BaseObject
    # field :plans, resolver: Resolvers::PlansResolver, description: "Fetch plans"
    field :fragments, resolver: Resolvers::FragmentsResolver, description: "Fetch fragments"
    # field :researchOutputs, resolver: Resolvers::ResearchOutputsResolver, description: "Fetch research outputs"

    field :plans, [PlanType], null: false do
      argument :filter, Types::LogicalFilterInput, required: false
    end

    def plans(filter: nil)
      scope = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve
      Resolvers::FiltersResolver.apply(scope, filter)&.map do |plan|
        plan.json_fragment.get_full_fragment
      end
    end
  end
end
