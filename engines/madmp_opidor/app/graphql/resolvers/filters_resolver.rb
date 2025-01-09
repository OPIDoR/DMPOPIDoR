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

      if field == "grantId"
        apply_grant_id_filter(scope, filter)
      else
        case operator
        when "eq"
          if value.is_a?(Array)
            scope.where("LOWER(#{field}) IN (?)", value.map(&:downcase))
          else
            scope.where("LOWER(#{field}) = ?", value.downcase)
          end
        when "neq"
          if value.is_a?(Array)
            scope.where.not("LOWER(#{field}) IN (?)", value.map(&:downcase))
          else
            scope.where.not("LOWER(#{field}) = ?", value.downcase)
          end
        when "like"
          if value.is_a?(Array)
            conditions = value.map { |v| "LOWER(#{field}) ILIKE ?" }
            scope.where(conditions.join(" OR "), *value.map { |v| "%#{v.downcase}%" })
          else
            scope.where("LOWER(#{field}) ILIKE ?", "%#{value.downcase}%")
          end
        else
          scope
        end
      end
    end

    def self.apply_grant_id_filter(scope, filter)
      value = filter[:value]
      operator = filter[:operator] || "eq"

      scope.select do |plan|
        fragments_scope = plan&.json_fragment&.dmp_fragments

        case operator
        when "eq"
          fragments_scope&.where("data->>'grantId' ~* ?", value)&.exists?
        when "regex"
          regex = value["regex"].gsub(/\A\/|\/\z/, '')
          fragments_scope&.where("data->>'grantId' ~* ?", regex)&.exists?
        when "in"
          fragments_scope&.where("LOWER(data->>'grantId') IN (?)", value.compact.uniq.map(&:downcase)) || []
        else
          fragments_scope
        end
      end
    end
  end
end
