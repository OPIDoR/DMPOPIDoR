module Types
  class QueryType < Types::BaseObject
    field :plans, resolver: Resolvers::PlansResolver, description: "Fetch plans"
    field :fragments, resolver: Resolvers::FragmentsResolver, description: "Fetch fragments"
  end
end