# frozen_string_literal: true

# Security policies for research outputs
module Dmpopidor
  module ResearchOutputPolicy
    def import?
      @research_output.plan.administerable_by?(@user.id)
    end
  end
end
