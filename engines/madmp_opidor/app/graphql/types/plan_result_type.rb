# frozen_string_literal: true

module Types
  # PlanResultType
  class PlanResultType < Types::BaseObject
    field :count, Integer, null: false
    # field :pages, Integer, null: false
    field :items, [Types::PlanType], null: false
  end
end
