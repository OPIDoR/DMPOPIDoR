# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    field :plans, [PlanType], null: false do
      argument :filter, Types::LogicalFilterInput, required: false
      argument :size, Integer, required: false, default_value: 10, description: 'Number of items to fetch'
      argument :offset, Integer, required: false, default_value: 0, description: 'Offset for pagination'
      description 'Fetch plans with optional filtering'
    end

    def plans(filter: nil, size: 10, offset: 0)
      plans = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      # return plans.map { |plan| plan&.json_fragment&.get_full_fragment(with_ids: true, with_template_name: true) } if filter.nil?
      return plans.map { |plan| plan&.json_fragment&.get_full_fragment } if filter.nil?

      fragments_by_plan_id = MadmpFragment.where("(data->>'plan_id')::int IN (?)", plans&.map(&:id))
      fragments_by_plan_id.flat_map do |fragment|
        Resolvers::PlansFiltersResolver.apply(fragment.dmp_fragments, filter, fragment.id)&.map do |madmp_fragment|
          # madmp_fragment&.dmp&.get_full_fragment(with_ids: true, with_template_name: true)
          madmp_fragment&.dmp&.get_full_fragment
        end
      end.compact # rubocop:disable Style/MultilineBlockChain
    end
  end
end
