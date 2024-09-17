module Types
  class PlanFilterInputType < Types::BaseInputObject
    argument :id, String, required: false
    argument :title, String, required: false
    argument :grantId, GraphQL::Types::JSON, required: false
  end
end