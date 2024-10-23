module Types
  class FragmentFilterInputType < Types::BaseInputObject
    argument :grantId, GraphQL::Types::JSON, required: false
    argument :fieldName, String, required: false
    argument :value, String, required: false
    argument :className, String, required: false
  end
end