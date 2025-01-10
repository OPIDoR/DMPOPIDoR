module Resolvers
  class FiltersResolver
    def self.apply(scope, filter)
      return scope if filter.nil?

      conditions = []

      if filter[:and]
        and_condition = filter[:and].reduce(nil) do |current_scope, sub_filter|
          sub_condition = build_condition(scope, sub_filter)
          current_scope ? current_scope.and(sub_condition) : sub_condition
        end
        conditions << and_condition
      end

      if filter[:or]
        or_condition = filter[:or].reduce(nil) do |current_scope, sub_filter|
          sub_condition = build_condition(scope, sub_filter)
          current_scope ? current_scope.or(sub_condition) : sub_condition
        end
        conditions << or_condition
      end

      if filter[:not]
        not_condition = build_condition(scope, filter[:not])
        conditions << scope.where.not(not_condition)
      end

      conditions.reduce(scope) { |current_scope, condition| current_scope.merge(condition) }
    end

    def self.build_condition(scope, filter)
      field = filter[:field]
      if field == "grantId"
        build_grant_id_condition(scope, filter)
      else
        apply_single_filter(scope, filter)
      end
    end

    def self.apply_single_filter(scope, filter)
      field = filter[:field]
      value = filter[:value]
      operator = filter[:operator] || "eq"

      matching_ids = scope.select do |plan|
        fragments_scope = plan&.json_fragment&.dmp_fragments
        next false unless fragments_scope

        case operator
        when "eq"
          if value.is_a?(Array)
            fragments_scope.any? { |fragment| fragment.data[field]&.downcase == value&.downcase }
          else
            fragments_scope.any? { |fragment| fragment.data[field]&.downcase == value&.downcase }
          end
        when "neq"
          fragments_scope.none? { |fragment| fragment.data[field]&.downcase == value&.downcase }
        when "like"
          fragments_scope.any? { |fragment| fragment.data[field]&.downcase&.include?(value.downcase) }
        when "regex"
          regex = value.gsub(/\A\/|\/\z/, '')
          fragments_scope.any? { |fragment| fragment.data[field] =~ Regexp.new(regex) }
        else
          scope
        end
      end.map(&:id)

      scope.where(id: matching_ids)
    end

    def self.build_grant_id_condition(scope, filter)
      value = filter[:value]
      operator = filter[:operator] || "eq"

      matching_ids = scope.select do |plan|
        fragments_scope = plan&.json_fragment&.dmp_fragments
        next false unless fragments_scope

        case operator
        when "eq"
          if value.is_a?(Array)
            fragments_scope.any? { |fragment| value.include?(fragment.data['grantId']&.downcase) }
          else
            fragments_scope.any? { |fragment| fragment.data['grantId']&.downcase == value.downcase }
          end
        when "like"
          if value.is_a?(Array)
            fragments_scope.any? { |fragment| value.any? { |v| fragment.data['grantId']&.downcase =~ /#{v.downcase}/i } }
          else
            fragments_scope.any? { |fragment| fragment.data['grantId']&.downcase =~ /#{value.downcase}/i }
          end
        when "regex"
          regex = Regexp.new(value.gsub(/\A\/|\/\z/, ''))
          fragments_scope.any? { |fragment| fragment.data['grantId'] =~ regex }
        else
          false
        end
      end.map(&:id)

      scope.where(id: matching_ids)
    end

  end
end
