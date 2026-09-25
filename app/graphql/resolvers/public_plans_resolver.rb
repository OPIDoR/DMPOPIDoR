# frozen_string_literal: true

module Resolvers
  # PublicPlansResolver is responsible for resolving a paginated list of
  # publicly visible plans based on optional filters and sorting criteria.
  class PublicPlansResolver < PlansResolver
    private

    def base_scope
      Plan.where(visibility: Plan.visibilities[:publicly_visible])
    end
  end
end
