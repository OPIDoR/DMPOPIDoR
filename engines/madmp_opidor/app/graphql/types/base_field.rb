# frozen_string_literal: true

module Types
  # BaseField
  class BaseField < GraphQL::Schema::Field
    argument_class Types::BaseArgument
  end
end
