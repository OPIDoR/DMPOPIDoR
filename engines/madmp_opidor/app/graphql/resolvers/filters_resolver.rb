module Resolvers
  class FiltersResolver
    def self.apply(scope, filter)
      return scope if filter.nil?

      if filter[:and]
        filter[:and].reduce(scope) do |current_scope, sub_filter|
          apply(current_scope, sub_filter)
        end
      elsif filter[:or]
        filters = filter[:or].map { |sub_filter| apply(scope, sub_filter).where_clause.ast }
        scope.where(filters.reduce { |acc, query| acc.or(query) })
      elsif filter[:not]
        scope.where.not(apply(scope, filter[:not]).where_clause.ast)
      else
        apply_single_filter(scope, filter)
      end
    end

    def self.apply_single_filter(scope, filter)
      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || "eq"

      case operator
      when "eq"
        scope.where(field => value)
      when "neq"
        scope.where.not(field => value)
      when "like"
        scope.where("LOWER(#{field}) ILIKE LOWER(?)", "%#{value}%")
      else
        scope
      end
    end
  end
end
