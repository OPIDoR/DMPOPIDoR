# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :fragments, [Types::FragmentType], null: true, resolver: Resolvers::FragmentsResolver
    field :visibility, Boolean, null: false

    def fragments(object, filter: nil)
      Resolvers::FragmentsResolver.new(object: object, context: context).resolve(filter: filter)
    end
  end
end
