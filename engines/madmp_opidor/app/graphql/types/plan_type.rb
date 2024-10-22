module Types
  class PlanType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :fragments, [Types::FragmentType], null: false, resolver: Resolvers::FragmentsResolver
  end
end
