# frozen_string_literal: true

module Types
  # PlanType
  class PlanType < Types::BaseObject
    field :plan_id, ID, null: false
    field :meta, GraphQL::Types::JSON, null: true
    field :project, GraphQL::Types::JSON, null: true
    field :researchEntity, GraphQL::Types::JSON, null: true
    field :budget, GraphQL::Types::JSON, null: true
    field :templateName, String, null: true
    field :researchOutput, GraphQL::Types::JSON, null: true

=begin
    def researchOutput
      ids = object["researchOutput"].map { |ro| ro["research_output_id"] }

      research_outputs = ResearchOutput.where(id: ids).index_by(&:id)

      object["researchOutput"].map do |ro|
        research_output = research_outputs[ro["research_output_id"]]
        next unless research_output

        research_output_fragment = research_output.json_fragment.as_json

        if research_output_fragment.key?("additional_info")
          research_output_fragment["configuration"] = research_output_fragment.delete("additional_info")

          research_output_fragment["configuration"].delete("property_name") if research_output_fragment["configuration"].is_a?(Hash)
        end

        research_output_fragment
      end.compact
    end
=end
  end
end
