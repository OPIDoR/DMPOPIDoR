module Types
  class LogicalFilterInput < Types::BaseInputObject
    argument :and, [LogicalFilterInput], required: false, description: "Combine conditions with a logical AND"
    argument :or, [LogicalFilterInput], required: false, description: "Combine conditions with a logical OR"
    argument :not, LogicalFilterInput, required: false, description: "Invert the condition"
    argument :field, String, required: false, description: "Field to filter on"
    argument :value, GraphQL::Types::JSON, required: false, description: "Value to use for the filter"
    argument :operator, String, required: false, description: "Comparison operator (eq, neq, gt, lt, etc.)"
  end
end
