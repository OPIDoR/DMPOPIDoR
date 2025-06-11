# frozen_string_literal: true

module Types
  # PlanResultType
  class PlanResultType < Types::BaseObject
    field :pageInfo, Types::PageInfoType, null: false, description: 'Pagination details, including total items, total pages, and the current page number.'
    field :items, [Types::PlanType], null: false, description: 'A paginated list of plans that match the search criteria.'
  end
end
