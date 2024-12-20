# frozen_string_literal: true

module Dmpopidor
  module Paginable
    # Security rules for plan tables
    module PlanPolicy
      def administrator_visible?
        @record.is_a?(User)
      end
    end
  end
end
