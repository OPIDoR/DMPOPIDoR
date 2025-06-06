# frozen_string_literal: true

plan = dmp.plan
meta = dmp.meta
research_outputs = plan.research_outputs.order(:display_order)

json.prettify!

json.meta meta.get_full_fragment

if plan.research_entity?
  json.researchEntity dmp.research_entity.get_full_fragment
else
  json.project dmp.project.get_full_fragment
end

json.contributor format_contributors(dmp)

json.researchOutput research_outputs do |research_output|
  research_output_fragment = research_output.json_fragment
  next unless selected_research_outputs.include?(research_output_fragment.data["research_output_id"])

  json.configuration research_output_fragment.additional_info.except('moduleId', 'property_name')
  json.merge! research_output_fragment.get_full_fragment
end
json.dmp_id dmp.id
