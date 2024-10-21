# frozen_string_literal: true

# Security policies for research outputs
module Dmpopidor
  # Security rules for research output tables
  module ResearchOutputPolicy
    def import?
      @research_output.plan.administerable_by?(@user.id)
    end
  end
end
