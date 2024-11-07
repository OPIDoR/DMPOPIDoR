# frozen_string_literal: true

module Types
  # PlanFilterInputType
  class PlanFilterInputType < Types::BaseInputObject
    argument :id, String, required: false
    argument :title, String, required: false
  end
end
