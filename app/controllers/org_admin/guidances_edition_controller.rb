# frozen_string_literal: true

module OrgAdmin
  # Controller that handles guidance and guidance_group edition
  class GuidancesEditionController < ApplicationController
    def index
      authorize Guidance
      guidances = Guidance.includes(:guidance_group, :themes)
                          .by_org(current_user.org)
      ensure_default_group(current_user.org)
      guidance_groups = GuidanceGroup.includes(:org)
                                     .by_org(current_user.org)

      render json: {
        guidance_groups: guidance_groups.map do |gg|
          GuidanceGroup.serialize_json_response(gg)
        end,
        guidances: guidances.map do |g|
          Guidance.serialize_json_response(g)
        end
      }
    end

    private

    def ensure_default_group(org)
      return unless org.managed?
      return if org.guidance_groups.where(optional_subset: false).present?

      GuidanceGroup.create_org_default(org)
    end
  end
end
