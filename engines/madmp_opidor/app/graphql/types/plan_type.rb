# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :fragments, GraphQL::Types::JSON, null: false
  end
end
