# frozen_string_literal: true

require 'jsonpath'
require 'json'

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    # field :templateName, String, null: true
    field :researchOutput, resolver: Resolvers::ResearchOutputsResolver do
      description 'Fetch research outputs'
    end
  end
end
