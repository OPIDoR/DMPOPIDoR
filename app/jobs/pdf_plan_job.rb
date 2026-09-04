# frozen_string_literal: true

# Job to create/update the JsonPlan for a Plan
class PdfPlanJob < ApplicationJob
  queue_as :default

  def perform(plan_id, user = nil)
    plan = Plan.includes(:answers, {
                           research_outputs: :guidance_groups, template: { phases: { sections: :questions } }
                         }).find_by(id: plan_id)
    return unless plan

    if plan.research_outputs.count >= ENV.fetch('PLAN_MINIMUM_RESEARCH_OUTPUTS',
                                                15).to_i || plan.publicly_visible?

      pdf_binary = Export::PlanPdfGenerator.new(plan, user || plan.owner, generate_options(plan)).call
      plan.update_column(:pdf_data, pdf_binary)
    else
      plan.update_column(:pdf_data, nil)
    end
  end

  private

  def generate_options(plan)
    options = {}
    options[:show_coversheet]         = true
    options[:show_sections_questions] = true
    options[:show_unanswered]         = true
    options[:show_custom_sections]    = true
    options[:show_research_outputs]   = true
    options[:public_plan] = (plan.publicly_visible? || false)
    options
  end
end
