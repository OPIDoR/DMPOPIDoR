module Resolvers
  class PlansResolver < BaseResolver
    type [Types::PlanType], null: true
    argument :id, GraphQL::Types::JSON, required: false, description: "ID of plan(s), can be a string or an array of strings."
    argument :grantId, GraphQL::Types::JSON, required: false

    def resolve(**args)
      filters = args

      plans = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      plans = apply_filters(plans, filters) if filters.present? && filters.any?

      plans&.map do |plan|
        plan.json_fragment.get_full_fragment
      end
    end

    def apply_filters(plans, filter)
      plans = filter_by_id(plans, filter[:id]) if filter[:id].present?
      plans = filter_by_grant_id(plans, filter[:grantId]) if filter[:grantId].present?
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

    def filter_by_grant_id(plans, grant_ids)
      plans.select do |plan|
        fragments = plan&.json_fragment&.dmp_fragments
        if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
          regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
          fragments&.where("data->>'grantId' ~* ?", regex)&.exists?
        elsif grant_ids.is_a?(Array)
          fragments&.where("data->>'grantId' IN (?)", grant_ids.compact.uniq)&.exists?
        else
          fragments&.where("data->>grantId = ?", grant_ids)&.exists?
        end
      end
    end

  end
end
