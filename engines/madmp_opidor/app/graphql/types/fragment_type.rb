module Types
  class FragmentType < Types::BaseObject
    field :plan, GraphQL::Types::JSON, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
  end
end
