module Resolvers
  class PlansResolver < BaseResolver
    type [Types::PlanType], null: true
    argument :id, GraphQL::Types::JSON, required: false, description: "ID of plan(s), can be a string or an array of strings."

    def resolve(id: nil)
      plans = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      id = object.dmp_id if object.respond_to?(:id)

      filter = { id: id }
      plans = apply_filters(plans, filter)

      plans
    end

    def apply_filters(plans, filter)
      plans = filter_by_id(plans, filter[:id]) if filter[:id].present?
      plans
    end

    private

    def filter_by_id(plans, id)
      if id.is_a?(Array)
        plans.where(id: id.compact.uniq)
      else
        plans.where(id: id)
      end
    end

  end
end
