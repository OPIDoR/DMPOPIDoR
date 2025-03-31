module Types
  # PageInfoType
  class PageInfoType < Types::BaseObject
    field :total, Integer, null: false, description: 'Total number of items available'
    field :totalPages, Integer, null: false, description: 'Total number of pages based on the page size'
    field :page, Integer, null: false, description: 'Current page number in the pagination'
  end
end
