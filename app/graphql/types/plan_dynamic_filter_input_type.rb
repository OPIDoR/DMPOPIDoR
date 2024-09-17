module Types
  class PlanDynamicFilterInputType < Types::BaseInputObject
    argument :name, String, required: true
    argument :value, GraphQL::Types::JSON, required: true
  end
end