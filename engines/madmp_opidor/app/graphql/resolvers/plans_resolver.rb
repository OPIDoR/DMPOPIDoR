# frozen_string_literal: true

module Resolvers
  # PlansResolver
  class PlansResolver < BaseResolver
    type [Types::PlanType], null: true
    argument :filter, Types::PlanFilterInputType, required: false

    def resolve(filter: nil)
      plans = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      plans = apply_filters(plans, filter) if filter.present?

      plans
    end

    def apply_filters(plans, filter)
      plans = filter_by_id(plans, filter.id) if filter.id.present?

      plans = filter_by_grant_id(plans, filter.grantId) if filter.grantId.present?

      if filter.fieldName.present? && filter.value.present?
        plans = filter_by_field_name(plans, filter.fieldName, filter.value)
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

    # rubocop:disable Metrics/AbcSize
    def filter_by_grant_id(plans, grant_ids)
      if grant_ids.is_a?(Hash) && grant_ids['regex'].present?
        regex = grant_ids['regex'].gsub(%r{\A/|/\z}, '')
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
    # rubocop:enable Metrics/AbcSize

    def filter_by_field_name(_plans, field_name, value)
      MadmpFragment.where('data->>? = ?', field_name, value).map do |fragment|
        {
          id: fragment.plan.id,
          title: fragment.plan.title,
          fragments: fragment.plan.json_fragment.get_full_fragment
        }
      end
    end
  end
end
