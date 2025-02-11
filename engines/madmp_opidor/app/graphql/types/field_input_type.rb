# frozen_string_literal: true

module Types
  # FieldInputType
  class FieldInputType < Types::BaseInputObject
    argument :name, String, required: false
    argument :value, String, required: false
  end
end
