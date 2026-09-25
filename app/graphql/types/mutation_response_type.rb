# frozen_string_literal: true

module Types
  # MutationResponseType defines a standard response structure for GraphQL mutations,
  # including a status code, message, and success flag.
  class MutationResponseType < BaseObject
    field :code, Integer, null: false
    field :message, String, null: false
    field :success, Boolean, null: false
  end
end
