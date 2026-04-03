# frozen_string_literal: true

module Types
  # LogicalSubfilterInput
  class LogicalSubfilterInput < Types::BaseInputObject
    argument :and, -> { [Types::AndOrFilterInput::AndSubFilterInput] }, required: false, description: 'Combines multiple conditions using a logical AND operation.'
    argument :or, -> { [Types::AndOrFilterInput::OrSubFilterInput] }, required: false, description: 'Combines multiple conditions using a logical OR operation.'
  end
end
