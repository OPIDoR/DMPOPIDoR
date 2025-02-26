# frozen_string_literal: true

module Types
  # ProjectType
  class ProjectType < Types::BaseObject
    field :description, String, description: 'Project description', null: true
    field :principalInvestigator, GraphQL::Types::JSON, null: true
    field :role, String, description: 'Role', null: true
  end
end
