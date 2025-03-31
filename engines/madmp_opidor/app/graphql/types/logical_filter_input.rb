# frozen_string_literal: true

module Types
  # LogicalFilterInput
  class LogicalFilterInput < Types::BaseInputObject
    argument :and, [LogicalFilterInput], required: false, description: 'Combines multiple conditions using a logical AND operation.'
    argument :or, [LogicalFilterInput], required: false, description: 'Combines multiple conditions using a logical OR operation.'
    argument :className, Types::ClassnameEnum, required: false, description: 'Specifies the class name of the fragment to filter.'
    argument :field, String, required: false, description: 'The field to apply the filter on.'
    argument :value, GraphQL::Types::JSON, required: false, description: 'The value to compare against the specified field.'
    argument :operator, String, required: false, description: 'The comparison operator to use (e.g., eq for equals, neq for not equals, gt for greater than, lt for less than, etc.).'
    argument :filter, Types::LogicalFilterInput, required: false, description: 'A nested filter to allow complex filtering conditions.'
  end
end
