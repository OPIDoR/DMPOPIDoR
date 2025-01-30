module Resolvers
  class FiltersResolver
    def self.apply(scope, filter, size, offset)
      filtered_scope = apply_filters(scope, filter)

      filtered_scope = filtered_scope.offset(offset).limit(size) if size && offset

      filtered_scope
    end

    def self.apply_filters(scope, filter)
      return scope if filter.nil?

      scope = apply_and_conditions(scope, filter[:and]) if filter[:and].present?
      scope = apply_or_conditions(scope, filter[:or]) if filter[:or].present?
      scope = apply_not_conditions(scope, filter[:not]) if filter[:not].present?

      scope
    end

    def self.apply_and_conditions(scope, conditions)
      return scope if conditions.all? { |sub_filter| build_condition(scope, sub_filter).any? }

      scope.none
    end


    def self.apply_or_conditions(scope, conditions)
      if sub_scopes.any?
        combined_scope = sub_scopes.first
        sub_scopes.drop(1).each do |sub_scope|
          combined_scope = combined_scope.or(sub_scope)
        end
        scope = scope.merge(combined_scope)
      else
        Rails.logger.warn "No valid OR conditions found: #{conditions.inspect}"
        return scope.none
      end
      scope
    end

    def self.apply_not_conditions(scope, condition)
      not_condition = build_condition(scope, condition)

      if not_condition.present?
        scope.where.not(not_condition)
      else
        Rails.logger.warn "Invalid NOT condition: #{condition.inspect}"
        return scope.none
      end
    end

    def self.build_condition(scope, filter)
      return nil unless filter[:className] && filter[:field] && filter[:value]

      apply_single_filter(scope, filter)
    end

    def self.apply_single_filter(scope, filter)
      class_name = filter[:className]
      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || "eq"

      scope = scope.where('LOWER(classname) = ?', class_name.downcase)

      case operator
      when "eq"
        scope = scope.where("LOWER(data->>'#{field}') = ?", value.downcase)
      when "neq"
        scope = scope.where.not("LOWER(data->>'#{field}') = ?", value.downcase)
      when "like"
        scope = scope.where("LOWER(data->>'#{field}') LIKE ?", "%#{value.downcase}%")
      when "regex"
        regex = value.gsub(/\A\/|\/\z/, '')
        scope = scope.where("data->>'#{field}' ~* ?", regex)
      else
        Rails.logger.warn "Unknown operator: #{operator}"
        scope = scope
      end
      scope
    end
  end
end
