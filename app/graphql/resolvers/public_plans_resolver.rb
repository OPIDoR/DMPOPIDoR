
# frozen_string_literal: true

module Resolvers
  class PublicPlansResolver < PlansResolver
    private

    def base_scope
      Plan.where(visibility: Plan.visibilities[:publicly_visible])
    end
  end
end
