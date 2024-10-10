module Types
  class QueryType < Types::BaseObject
    field :plans, resolver: Resolvers::PlansResolver, description: "Fetch plans"
  end
end