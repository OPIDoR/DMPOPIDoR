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

      if filter.grantId.present?
        plans = filter_by_grant_id(plans, filter.grantId)
      end

      if filter.fieldName.present? && filter.value.present?
        plans = filter_by_fieldName(plans, filter.fieldName, filter.value)
      end

      plans
    end

    private

    def filter_by_id(plans, id)
      plans.where(id: id).map do |plan|
        {
          id: plan.id,
          title: plan.title,
          fragments: plan.json_fragment.get_full_fragment
        }
      end
    end

    def filter_by_grant_id(plans, grant_ids)
      if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
        regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
        plans = MadmpFragment.where("data->>'grantId' ~* ?", regex).map do |fragment|
          {
            id: fragment.plan.id,
            title: fragment.plan.title,
            fragments: fragment.plan.json_fragment.get_full_fragment
          }
        end
      elsif grant_ids.is_a?(Array)
        grant_ids = grant_ids.compact.uniq
        plans = MadmpFragment.where("data->>'grantId' IN (?)", grant_ids).map do |fragment|
          {
            id: fragment.plan.id,
            title: fragment.plan.title,
            fragments: fragment.plan.json_fragment.get_full_fragment
          }
        end
      end
      plans
    end

    def filter_by_fieldName(plans, field_name, value)
      MadmpFragment.where("data->>? = ?", field_name, value).map do |fragment|
        {
          id: fragment.plan.id,
          title: fragment.plan.title,
          fragments: fragment.plan.json_fragment.get_full_fragment
        }
      end
    end
  end
end