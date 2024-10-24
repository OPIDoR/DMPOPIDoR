module Resolvers
  class FragmentsResolver < BaseResolver
    type [Types::FragmentType], null: false
    argument :filter, Types::FragmentFilterInputType, required: false

    def resolve(filter: nil)
      fragments = apply_filters(filter) if filter.present?

      p "===================="
      p fragments
      p "===================="

      fragments
    end

    def apply_filters(filter)
      if filter.grantId.present?
        data = filter_by_grant_id(filter.grantId)
      end

      if filter.className.present?
        data = filter_by_class_name(filter.className)
      end

      if filter.fieldName.present? && filter.value.present?
        data = filter_by_fieldName(filter.fieldName, filter.value)
      end

      data
    end

    private

    def format_fragments(fragments)
      fragments.map do |fragment|
        if Api::V1::Madmp::MadmpFragmentsPolicy.new(context[:current_user], fragment).show?
          fragment
        end
      end.compact
    end

    def filter_by_grant_id(grant_ids)
      if grant_ids.is_a?(Hash) && grant_ids["regex"].present?
        regex = grant_ids["regex"].gsub(/\A\/|\/\z/, '')
        fragments = MadmpFragment.where("data->>'grantId' ~* ?", regex)
      elsif grant_ids.is_a?(Array)
        grant_ids = grant_ids.compact.uniq
        fragments = MadmpFragment.where("data->>'grantId' IN (?)", grant_ids)
      end
      format_fragments(fragments)
    end

    def filter_by_class_name(class_name)
      fragments = MadmpFragment.where(classname: class_name)
      format_fragments(fragments)
    end

    def filter_by_fieldName(field_name, value)
      fragments =  MadmpFragment.where("data->>? = ?", field_name, value)
      format_fragments(fragments)
    end
  end
end