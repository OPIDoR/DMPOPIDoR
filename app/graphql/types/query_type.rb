# frozen_string_literal: true

module Types
  # QueryType
  class QueryType < Types::BaseObject
    field :plans, Types::PlanResultType, null: false do
      instance_eval(&Types::SharedFields::SHARED_PLAN_ARGUMENTS)
      description 'Retrieve a paginated list of plans with optional filtering'
    end

    field :public_plans, Types::PlanResultType, null: false do
      instance_eval(&Types::SharedFields::SHARED_PLAN_ARGUMENTS)
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
      offset = (page - 1) * size

      plans_scope = plans_scope.where.not(
        visibility: [
          Plan.visibilities[:is_test],
        ]
      ) unless test

      plans_ids = plans_scope.pluck(:id)
      order_params = if order_by.nil? || order_by.empty?
                       Arel.sql("jsonb_path_query_first(data, '$.meta.lastModifiedDate') DESC")
                     else
                       order_by.map do |p|
                         Arel.sql("jsonb_path_query_first(data, '#{p.field}') #{p.order.to_s.upcase}")
                       end
                     end

      results = JsonPlan
                        .yield_self { |rel| filter.present? ? rel.where(*build_jsonb_filters(filter)) : rel }
                        .where(plan_id: plans_scope.select(:id))

      total_items = results.count
      total_pages = (total_items.to_f / size).ceil

      results = results.order(*order_params)
                   .limit(size)
                   .offset(offset)

      {
        pageInfo: {
          total: total_items,
          totalPages: total_pages,
          page: page,
        },
        items: results
      }
    end

    def build_jsonb_filters(filter)
      return nil unless filter.present?

      and_sql = build_conditions(filter[:and], "AND")
      or_sql  = build_conditions(filter[:or],  "OR")

      combined = [and_sql, or_sql].compact
      ["(#{combined.join(" OR ")})"] unless combined.empty?
    end

    def build_conditions(conditions, operator)
      return nil unless conditions.present?

      conditions.map { |c|
        jsonb_path_where(path: c[:field], value: c[:value], operator: c[:operator] || "eq")
      }.join(" #{operator} ")
    end

    def jsonb_path_where(path:, value:, operator: "eq")
      operator_map = {
        "eq"   => "==",
        "neq"  => "!=",
        "like" => "like_regex",
        "regex" => "like_regex",
        "gt"   => ">",
        "lt"   => "<",
        "gte"  => ">=",
        "lte"  => "<=",
      }

      op = operator_map[operator] || raise("Unsupported operator #{operator}")

      "jsonb_path_exists(data, '#{path} ? (@ #{op} #{value.inspect})')"
    end
  end
end
