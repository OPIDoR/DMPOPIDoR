# frozen_string_literal: true

module Types
  # ResearchOutputType
  class ResearchOutputType < Types::BaseObject
    field :research_output_id, GraphQL::Types::ID, null: false
    field :researchOutputDescription, GraphQL::Types::JSON, null: true
  end
end
