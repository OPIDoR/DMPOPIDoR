# frozen_string_literal: true

namespace :json_plans do
  desc 'Adding full plans in JSON format in json_plans table'
  task job: :environment do
    p 'Retrieving all structured plans'
    p '------------------------------------------------------------------------'
    plans = Plan.includes(:template).where(template: { type: 'structured' })
    p "> Total plans: #{plans.count}"
    p 'Adding plans in JSON format in table'

    errors = []

    plans.each do |plan|
      p "> Adding plan: #{plan.id}"
      json_plan = JsonPlan.find_or_initialize_by(plan: plan)
      json_plan.assign_attributes(
        dmp_id: plan.json_fragment.id,
        research_outputs_uuids: plan.research_outputs.pluck(:uuid),
        data: plan.json_fragment.get_full_fragment
      )
      json_plan.save!
    rescue StandardError => e
      p "> ERROR for plan #{plan.id}: #{e.message}"
      errors << { plan_id: plan.id, error: e.message }
    end

    p '------------------------------------------------------------------------'
    p 'Task complete'
    if errors.empty?
      p 'No errors encountered.'
    else
      p "#{errors.size} error(s) encountered:"
      errors.each { |err| p "> Plan #{err[:plan_id]}: #{err[:error]}" }
    end
  end
end
