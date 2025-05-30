# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    SHARED_PLAN_ARGUMENTS = Proc.new do
      argument :filter, Types::LogicalFilterInput, required: false, description: 'Optional filter to refine the list of plans'
      argument :size, Integer, required: false, default_value: 10, description: 'Number of items to retrieve per page'
      argument :page, Integer, required: false, default_value: 1, description: 'Page number for pagination'
      argument :test, GraphQL::Types::Boolean, required: false, default_value: false, description: 'Display tests plans'
      argument :order_by, Types::OrderByFilterInput, required: false, description: 'Specifies sorting order and field for the query'
    end

    field :plans, Types::PlanResultType, null: false do
      instance_eval(&SHARED_PLAN_ARGUMENTS)
      description 'Retrieve a paginated list of plans with optional filtering'
    end

    field :public_plans, Types::PlanResultType, null: false do
      instance_eval(&SHARED_PLAN_ARGUMENTS)
      description 'Retrieve a paginated list of public plans with optional filtering'
    end

    def plans(filter: nil, size: 10, page: 1, order_by: nil, test: false)
      plans_scope = Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve
      get_plans(filter, size, page, order_by, test, plans_scope)
    end

    def public_plans(filter: nil, size: 10, page: 1, order_by: nil, test: false)
      plans_scope = Plan.where(visibility: Plan.visibilities[:publicly_visible])
      get_plans(filter, size, page, order_by, test, plans_scope)
    end

    private

    def get_plans(filter, size, page, order_by, test, plans_scope)
      if size < 1 || size > 1000
        raise GraphQL::ExecutionError, "Size must be between 1 and 1000. Current size: #{size}."
      end

      order_params = {
        (order_by&.[](:field) || 'updated_at') => (order_by&.[](:order).presence || 'desc').to_sym
      }

      plans_scope = plans_scope.where.not(
        visibility: [
          Plan.visibilities[:is_test],
        ]
      ) unless test

      if filter.nil?
        total_items = plans_scope.count
        total_pages = (total_items.to_f / size).ceil
        offset = (page - 1) * size

        return {
          pageInfo: {
            total: total_items,
            totalPages: total_pages,
            page: page,
          },
          items: plans_scope.order(order_params)
                            .limit(size)
                            .offset(offset)
                            .map { |plan| plan.json_fragment.get_full_fragment }
        }
      end

      fragments_by_plan_id = MadmpFragment
                               .where("(data->>'plan_id')::int IN (?)", plans_scope.select(:id))
                               .order(order_params)

      results = fragments_by_plan_id.flat_map do |fragment|
        Resolvers::PlansFiltersResolver.apply(filter, fragment.id)[0]&.dmp&.get_full_fragment || []
      end.compact # rubocop:disable Style/MultilineBlockChain

      total_items = results.length
      total_pages = (total_items.to_f / size).ceil
      offset = (page - 1) * size

      paginated_results = results.slice(offset, size) || []

      {
        pageInfo: {
          total: total_items,
          totalPages: total_pages,
          page: page,
        },
        items: paginated_results
      }
    end
  end
end
