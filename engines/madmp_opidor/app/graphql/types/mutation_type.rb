# frozen_string_literal: true

module Types
  # MutationType
  class MutationType < Types::BaseObject
    field :authenticate, mutation: Mutations::Authenticate
    field :create_research_output, mutation: Mutations::CreateResearchOutput
  end
end
