module Resolvers
  class PlansResolver < BaseResolver
    type [Types::PlanType], null: true
    argument :filter, Types::PlanFilterInputType, required: false

    def resolve(filter: nil)
      plans = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      plans = apply_filters(plans, filter) if filter.present?

      plans
    end

    def apply_filters(plans, filter)
      if filter.id.present?
        plans = filter_by_id(plans, filter.id)
      end

      plans
    end

    private

    def filter_by_id(plans, id)
      plans.where(id: id).map do |plan|
        {
          id: plan.id,
          title: plan.title,
        }
      end
    end
  end
end