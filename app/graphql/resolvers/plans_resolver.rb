module Resolvers
  class PlansResolver < BaseResolver
    type [Types::PlanType], null: true
    argument :filter, Types::PlanFilterInputType, required: false

    # plans(filter: { grantId: ["XXXX", "YYYY"] }) {
    #   id
    #   title
    #   fragments
    # }

    def resolve(filter: nil)
      plans = Plan.all

      plans = apply_filters(plans, filter) if filter.present?

      plans
    end

    def apply_filters(plans, filter)
      plans = plans.where(id: filter.id) if filter.id.present?
      plans = plans.where(title: filter.title) if filter.title.present?

      if filter.grantId.present?
        plans = filter_by_grant_id(plans, filter.grantId)
      end

      plans
    end

    def filter_by_grant_id(plans, grant_ids)
      grant_ids = [grant_ids] unless grant_ids.is_a?(Array)
      grant_ids = grant_ids.compact.uniq

      MadmpFragment.where("data->>'type' IN (?)", grant_ids).map do |fragment|
        {
          id: fragment.plan.id,
          title: fragment.plan.title,
          fragments: fragment.plan.json_fragment.get_full_fragment
        }
      end
    end
  end
end