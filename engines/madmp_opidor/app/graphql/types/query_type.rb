# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    field :plans, resolver: Resolvers::PlansResolver, description: 'Fetch plans'
  end
end
