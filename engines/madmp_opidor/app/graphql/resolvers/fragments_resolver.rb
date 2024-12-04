module Resolvers
  class FragmentsResolver < BaseResolver
    type [Types::FragmentType], null: false

    argument :grantId, GraphQL::Types::JSON, required: false
    argument :className, String, required: false
    argument :field, Types::FieldInputType, required: false

    def resolve(**args)
      filters = args

      plans = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      fragments = apply_filters(plans, filters) if filters.present? && filters.any?

      fragments
    end

    def apply_filters(plans, filter)
      fragments = filter_by_grant_id(plans, filter[:grantId]) if filter[:grantId].present?
      fragments = filter_by_class_name(plans, filter[:className]) if filter[:className].present?

      if filter[:field].present? && filter[:field][:name].present? && filter[:field][:value].present?
        fragments = filter_by_field_name(plans, filter[:field][:name], filter[:field][:value])
      end

      fragments
    end

    private

    def filter_by_grant_id(plans, grant_ids)
      plans.flat_map do |plan|
        fragments = plan&.json_fragment&.dmp_fragments
        if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
          regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
          fragments&.where("data->>'grantId' ~* ?", regex) || []
        elsif grant_ids.is_a?(Array)
          fragments&.where("data->>'grantId' IN (?)", grant_ids.compact.uniq) || []
        else
          fragments&.where("data->>'grantId' = ?", grant_ids) || []
        end
      end
    end

    def filter_by_class_name(plans, class_name)
      plans.flat_map do |plan|
        fragments = plan&.json_fragment&.dmp_fragments
        fragments&.where(classname: class_name) || []
      end
    end

    def filter_by_field_name(plans, field_name, value)
      plans.flat_map do |plan|
        fragments = plan&.json_fragment&.dmp_fragments
        fragments&.where("data->>? = ?", field_name, value) || []
      end
    end
  end
end
