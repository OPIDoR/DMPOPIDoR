# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    field :plans, Types::PlanResultType, null: false do
      argument :filter, Types::LogicalFilterInput, required: false
      # argument :size, Integer, required: false, default_value: 10, description: 'Number of items to fetch'
      # argument :page, Integer, required: false, default_value: 1, description: 'Page for pagination'
      description 'Fetch plans with optional filtering'
    end

    def plans(filter: nil, size: 10, page: 1)
      plans_scope = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve

      offset = (page - 1) * size

      return {
        count: plans_scope.count,
        items: plans_scope.limit(size).offset(offset).map { |plan| plan.json_fragment.get_full_fragment }
      } if filter.nil?

      if filter.nil?
        {
          count: plans_scope.length,
          # pages: (plans_scope.length / size).ceil,
          items: plans_scope
        }
      end

      fragments_by_plan_id = MadmpFragment
                               .where("(data->>'plan_id')::int IN (?)", plans_scope.select(:id))
                               # .limit(size)
                               # .offset(offset)

      results = fragments_by_plan_id.flat_map do |fragment|
        Resolvers::PlansFiltersResolver.apply(fragment.dmp_fragments, filter, fragment.id)&.map do |madmp_fragment|
          madmp_fragment&.dmp&.get_full_fragment
        end
      end.compact # rubocop:disable Style/MultilineBlockChain

      {
        count: results.length,
        # pages: (plans_scope.length / size).ceil,
        items: results
      }
    end
  end
end
