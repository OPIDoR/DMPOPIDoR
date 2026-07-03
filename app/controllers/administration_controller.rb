# frozen_string_literal: true

# Administration controller displaying pages for org admins
class AdministrationController < ApplicationController
  def guidances_management
    authorize Guidance, policy_class: AdministrationPolicy
  end

  private

  def ensure_default_group(org)
    return unless org.managed?
    return if org.guidance_groups.length.positive?

    GuidanceGroup.create_org_default(org)
  end
end
