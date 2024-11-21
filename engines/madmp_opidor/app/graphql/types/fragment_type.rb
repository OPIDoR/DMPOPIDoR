module Types
  class FragmentType < Types::BaseObject
    field :id, ID, null: false
    field :dmp_id, Integer, null: true
    field :classname, String, null: false
    field :data, GraphQL::Types::JSON, null: true
    field :plan, [Types::PlanType], null: true, resolver: Resolvers::PlansResolver

    def plan(object, filter: nil)
      Resolvers::PlansResolver.new(object: object, context: context).resolve(filter: filter)
    end
  end
end
