module Resolvers
  class FragmentsResolver < BaseResolver
    type [Types::FragmentType], null: false
    argument :filter, Types::FragmentFilterInputType, required: false

    def resolve(filter: nil)
      fragments = apply_filters(filter) if filter.present?

      fragments
    end

    def apply_filters(filter)
      if filter.grantId.present?
        data = filter_by_grant_id(filter.grantId)
      end

      if filter.fieldName.present? && filter.value.present?
        data = filter_by_fieldName(filter.fieldName, filter.value)
      end

      data
    end

    private

    def filter_by_grant_id(grant_ids)
      if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
        regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
        fragments = MadmpFragment.where("data->>'grantId' ~* ?", regex).map do |fragment|
          if Api::V1::Madmp::MadmpFragmentsPolicy.new(context[:current_user], fragment).show?
            {
              plan: fragment.plan
            }.merge(fragment.plan.json_fragment.get_full_fragment)
          else
            nil
          end
        end.compact
      elsif grant_ids.is_a?(Array)
        grant_ids = grant_ids.compact.uniq
        fragments = MadmpFragment.where("data->>'grantId' IN (?)", grant_ids).map do |fragment|
          if Api::V1::Madmp::MadmpFragmentsPolicy.new(context[:current_user], fragment).show?
            {
              plan: fragment.plan
            }.merge(fragment.plan.json_fragment.get_full_fragment)
          else
            nil
          end
        end.compact
      end
      fragments
    end

    def filter_by_fieldName(field_name, value)
      MadmpFragment.where("data->>? = ?", field_name, value).map do |fragment|
        if Api::V1::Madmp::MadmpFragmentsPolicy.new(context[:current_user], fragment).show?
          {
            plan: fragment.plan
          }.merge(fragment.plan.json_fragment.get_full_fragment)
        else
          nil
        end
      end.compact
    end
  end
end