# frozen_string_literal: true

module Types
  #  Operator
  class OperatorEnum < Types::BaseEnum
    value "eq", "Equal", value: "eq"
    value "neq", "Not equal", value: "neq"
    value "like", "Like (regex)", value: "like"
    value "regex", "Regex match", value: "regex"
    value "gt", "Greater than", value: "gt"
    value "lt", "Less than", value: "lt"
    value "gte", "Greater or equal", value: "gte"
    value "lte", "Less or equal", value: "lte"
    value "in", "In list", value: "in"
  end
end
