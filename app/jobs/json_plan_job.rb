# frozen_string_literal: true

# Job to create/update the JsonPlan for a Plan
class JsonPlanJob < ApplicationJob
  queue_as :default

  def perform(plan_id:)
    plan = Plan.find_by(id: plan_id)
    return unless plan

    json_plan = JsonPlan.find_or_initialize_by(plan: plan)
    json_plan.assign_attributes(
      dmp_id: plan.json_fragment.id,
      research_outputs_uuids: plan.research_outputs.pluck(:uuid),
      data: plan.json_fragment.get_full_fragment(with_configuration: true, with_guidance_groups: true)
    )
    json_plan.save!
  end
end
