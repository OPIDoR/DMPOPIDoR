
# frozen_string_literal: true

module Resolvers
  class PlansResolver < GraphQL::Schema::Resolver
    type Types::PlanResultType, null: false
    instance_eval(&Types::SharedFields::SHARED_PLAN_ARGUMENTS)

    def resolve(filter: nil, size: 10, page: 1, order_by: nil, test: false)
      plans_scope = base_scope
      fetch_plans(filter, size, page, order_by, test, plans_scope)
    end

    private

    def base_scope
      Api::V1::PlansPolicy::Scope.new(context[:current_user], Plan).resolve
    end

    def fetch_plans(filter, size, page, order_by, test, plans_scope)
      offset = (page - 1) * size

      plans_scope = plans_scope.where.not(
        visibility: [
          Plan.visibilities[:is_test],
        ]
      ) unless test

      order_params = if order_by.nil? || order_by.empty?
                       Arel.sql("jsonb_path_query_first(data, '$.meta.lastModifiedDate') DESC")
                     else
                       order_by.map do |p|
                         Arel.sql("jsonb_path_query_first(data, '#{p.field}') #{p.order.to_s.upcase}")
                       end
                     end

      results = JsonPlan
                  .yield_self { |rel| filter.present? ? rel.where(*Resolvers::JsonbResolver.build_jsonb_filters(filter, field: "data")) : rel }
                  .where(plan_id: plans_scope.select(:id))

      total_items = results.count
      total_pages = (total_items.to_f / size).ceil

      results = results.order(*order_params)
                       .limit(size)
                       .offset(offset)
                       .pluck(:data)

      {
        pageInfo: {
          total: total_items,
          totalPages: total_pages,
          page: page
        },
        items: results
      }
    end
  end
end
