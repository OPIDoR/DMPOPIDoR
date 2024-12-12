module Types
  class QueryType < Types::BaseObject
    field :plans, resolver: Resolvers::PlansResolver, description: "Fetch plans"
    field :fragments, resolver: Resolvers::FragmentsResolver, description: "Fetch fragments"
    # field :researchOutputs, resolver: Resolvers::ResearchOutputsResolver, description: "Fetch research outputs"
  end
end
