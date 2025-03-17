# frozen_string_literal: true

module Types
  # PlanResultType
  class PlanResultType < Types::BaseObject
    field :totalCount, Integer, null: false
    field :items, [Types::PlanType], null: false
  end
end
