# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
  end
end
