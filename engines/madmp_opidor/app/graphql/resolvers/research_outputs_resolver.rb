# frozen_string_literal: true

module Resolvers
  # ResearchOutputsResolver
  class ResearchOutputsResolver < BaseResolver
    def resolve(**args); end

    def apply_filters(filter); end

    private

    def research_outputs_policy(research_outputs); end
  end
end
