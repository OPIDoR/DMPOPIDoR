# frozen_string_literal: true

module Types
  # MetaType
  class MetaType < Types::BaseObject
    field :title, String, description: 'Plan title'
    field :creationDate, String, description: 'Creation date'
    field :lastModifiedDate, String, description: 'Update date'
    field :dmpLanguage, String, description: 'Plan language'
    field :dmpId, ID, null: true, description: 'DMP ID'
    field :contact, GraphQL::Types::JSON, null: true
  end
end
