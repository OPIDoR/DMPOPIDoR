# frozen_string_literal: true
#
module Types
  module SharedFields
    def self.shared_and_or_filter
      Proc.new do
        # argument :className, Types::ClassnameEnum, required: false, description: 'Specifies the class name of the fragment to filter.'
        argument :field, String, required: false, description: 'The field to apply the filter on.'
        argument :value, GraphQL::Types::JSON, required: false, description: 'The value to compare against the specified field.'
        argument :operator, Types::OperatorEnum, required: false, description: 'The comparison operator to use.'
        argument :filter, -> { Types::LogicalFilterInput }, required: false, description: 'A nested filter to allow complex filtering conditions.'
      end
    end

    SHARED_PLAN_ARGUMENTS = Proc.new do
      argument :filter, Types::LogicalFilterInput, required: false, description: 'Optional filter to refine the list of plans'
      argument :size, Integer, required: false, default_value: 10, description: 'Number of items to retrieve per page (must be between 1 and 1000)', prepare: ->(value, ctx) {
        raise GraphQL::ExecutionError, "size must be between 1 and 1000" unless value.between?(1, 1000)
        value
      }
      argument :page, Integer, required: false, default_value: 1, description: 'Page number for pagination (must be greater than 0)', prepare: ->(value, ctx) {
        v = value || 1
        raise GraphQL::ExecutionError, "page must be greater than 0" if v <= 0
        v
      }
      argument :test, GraphQL::Types::Boolean, required: false, default_value: false, description: 'Display tests plans'
      argument :order_by, [Types::OrderByFilterInput, null: false], required: false, description: 'Specifies sorting order and field for the query'
    end
  end
end
