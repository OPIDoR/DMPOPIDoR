# frozen_string_literal: true

module Types
  # OrderByFilterInput
  class OrderByFilterInput < Types::BaseInputObject
    argument :field, String, required: true, default_value: 'updated_at', description: 'Field to sort by'
    argument :order, String, required: true, default_value: 'desc', description: 'Sort order (asc or desc)'
  end
end
