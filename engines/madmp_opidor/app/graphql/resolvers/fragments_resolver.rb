module Resolvers
  class FragmentsResolver < BaseResolver
    type [Types::FragmentType], null: false

    argument :grantId, GraphQL::Types::JSON, required: false
    argument :className, String, required: false
    argument :field, Types::FieldInputType, required: false

    def resolve(**args)
      filter = args

      plan_id = object.id if object.respond_to?(:id)

      fragments = plan_id ? MadmpFragment.where(dmp_id: plan_id) : MadmpFragment.all

      fragments = apply_filters(fragments, filter) if filter.present? && filter.any?

      format_fragments(fragments)
    end

    def apply_filters(fragments, filter)
      fragments = filter_by_grant_id(fragments, filter[:grantId]) if filter[:grantId].present?
      fragments = filter_by_class_name(fragments, filter[:className]) if filter[:className].present?

      if filter[:field].present? && filter[:field][:name].present? && filter[:field][:value].present?
        fragments = filter_by_field_name(fragments, filter[:field][:name], filter[:field][:value])
      end

      fragments
    end

    private

    def format_fragments(fragments)
      fragments.select { |fragment| Api::V1::Madmp::MadmpFragmentsPolicy.new(context[:current_user], fragment).show? }
    end

    def filter_by_grant_id(fragments, grant_ids)
      if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
        regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
        fragments = fragments.where("data->>'grantId' ~* ?", regex)
      elsif grant_ids.is_a?(Array)
        fragments = fragments.where("data->>'grantId' IN (?)", grant_ids.compact.uniq)
      end
      fragments
    end

    def filter_by_class_name(fragments, class_name)
      fragments.where(classname: class_name)
    end

    def filter_by_field_name(fragments, field_name, value)
      fragments.where("data->>? = ?", field_name, value)
    end
  end
end
