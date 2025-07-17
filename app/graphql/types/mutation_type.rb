# frozen_string_literal: true

module Types
  # MutationType
  class MutationType < Types::BaseObject
    field :authenticate, mutation: Mutations::Authenticate
    field :create_research_output, mutation: Mutations::CreateResearchOutput
    field :update_research_output, mutation: Mutations::UpdateResearchOutput
    field :create_plan, mutation: Mutations::CreatePlan
  end
end
