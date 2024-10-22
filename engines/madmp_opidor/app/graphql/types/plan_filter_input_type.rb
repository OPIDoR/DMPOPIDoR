module Types
  class PlanFilterInputType < Types::BaseInputObject
    argument :id, String, required: false
    argument :title, String, required: false
  end
end