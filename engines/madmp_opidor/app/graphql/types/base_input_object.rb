# frozen_string_literal: true

module Types
  # BaseInputObject
  class BaseInputObject < GraphQL::Schema::InputObject
    argument_class Types::BaseArgument
  end
end
