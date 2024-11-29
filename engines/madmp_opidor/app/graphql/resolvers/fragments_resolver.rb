module Resolvers
  class FragmentsResolver < BaseResolver
    type [Types::FragmentType], null: false

    argument :grantId, GraphQL::Types::JSON, required: false
    argument :className, String, required: false
    argument :field, Types::FieldInputType, required: false

    def resolve(**args)
      filters = args

      fragments = apply_filters(filters) if filters.present? && filters.any?

      fragments_policy(fragments)
    end

    def apply_filters(filter)
      fragments = filter_by_grant_id(filter[:grantId]) if filter[:grantId].present?
      fragments = filter_by_class_name(filter[:className]) if filter[:className].present?

      if filter[:field].present? && filter[:field][:name].present? && filter[:field][:value].present?
        fragments = filter_by_field_name(filter[:field][:name], filter[:field][:value])
      end

      fragments
    end

    private

    def fragments_policy(fragments)
      fragments.select { |fragment| Api::V1::Madmp::MadmpFragmentsPolicy.new(context[:current_user], fragment).show? }
    end

    def filter_by_grant_id(grant_ids)
      if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
        regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
        fragments = MadmpFragment.where("data->>'grantId' ~* ?", regex)
      elsif grant_ids.is_a?(Array)
        fragments = MadmpFragment.where("data->>'grantId' IN (?)", grant_ids.compact.uniq)
      end
      fragments
    end

    def filter_by_class_name(class_name)
      MadmpFragment.where(classname: class_name)
    end

    def filter_by_field_name( field_name, value)
      MadmpFragment.where("data->>? = ?", field_name, value)
    end
  end
end
