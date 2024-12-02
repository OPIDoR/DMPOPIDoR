# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    # field :id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    # field :fragments, [Types::FragmentType], null: true, resolver: Resolvers::FragmentsResolver
    # field :visibility, Boolean, null: false

    # def fragments(object, filter: nil)
    #  Resolvers::FragmentsResolver.new(object: object, context: context).resolve(filter: filter)
    # end
  end
end
