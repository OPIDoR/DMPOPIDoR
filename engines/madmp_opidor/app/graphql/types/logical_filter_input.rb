# frozen_string_literal: true

module Types
  # LogicalFilterInput
  class LogicalFilterInput < Types::BaseInputObject
    argument :and, [LogicalFilterInput], required: false, description: 'Combine conditions with a logical AND'
    argument :or, [LogicalFilterInput], required: false, description: 'Combine conditions with a logical OR'
    argument :className, String, required: false, description: 'Fragment class name'
    argument :field, String, required: false, description: 'Field to filter on'
    argument :value, GraphQL::Types::JSON, required: false, description: 'Value to use for the filter'
    argument :operator, String, required: false, description: 'Comparison operator (eq, neq, gt, lt, etc.)'
  end
end
