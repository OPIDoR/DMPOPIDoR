# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    field :plans, resolver: Resolvers::PlansResolver do
      description 'Retrieve a paginated list of plans with optional filtering'
    end

    field :public_plans, resolver: Resolvers::PublicPlansResolver do
      description 'Retrieve a paginated list of public plans with optional filtering'
    end
  end
end
