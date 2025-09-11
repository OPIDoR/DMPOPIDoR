# frozen_string_literal: true

module Types
  # LogicalFilterInput
  class LogicalFilterInput < Types::BaseInputObject
    argument :and, -> { [Types::AndOrFilterInput::AndFilterInput] }, required: false, description: 'Combines multiple conditions using a logical AND operation.'
    argument :or, -> { [Types::AndOrFilterInput::OrFilterInput] }, required: false, description: 'Combines multiple conditions using a logical OR operation.'
  end
end
