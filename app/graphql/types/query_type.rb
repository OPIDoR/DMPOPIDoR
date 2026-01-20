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
      order_params = order_by.map do |p|
        Arel.sql("jsonb_path_query_first(data, '#{p.field}') #{p.order.to_s.upcase}")
      end

      results = JsonPlan
                        .yield_self { |rel| filter.present? ? rel.where(*build_jsonb_filters(filter)) : rel }
                        .where(plan_id: plans_ids)
                        .order(*order_params)
                        .limit(size)
                        .offset(offset)

      total_items = results.count
      total_pages = (total_items.to_f / size).ceil

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

      and_sql = if filter[:and].present?
                  filter[:and].map { |c|
                    jsonb_path_where(path: c[:field], value: c[:value], operator: c[:operator] || "eq")
                  }.join(" AND ")
                end

      or_sql = if filter[:or].present?
                 filter[:or].map { |c|
                   jsonb_path_where(path: c[:field], value: c[:value], operator: c[:operator] || "eq")
                 }.join(" OR ")
               end

      combined = []
      combined << "(#{and_sql})" if and_sql.present?
      combined << "(#{or_sql})"  if or_sql.present?

      ["(#{combined.join(" OR ")})"]
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
