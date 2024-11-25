# frozen_string_literal: true

module Dmpopidor
  # Customized code for Org model
  module Template
    def serialize_json
      section_data = sections.as_json(
        include: {
          questions: {
            only: %w[id text number default_value question_format_id],
            include: { madmp_schema: { only: %w[id classname] } }
          }
        }
      )
      {
        id: id,
        locale: locale,
        title: title,
        version: version,
        org: org&.name,
        structured: structured?,
        publishedDate: updated_at.to_date,
        sections: section_data
      }
    end

    #
    # CHANGES : Added module template support
    #
    def removable?
      versions = ::Template.includes(:plans).where(family_id: family_id)
      if type.eql?('module')
        Fragment::ResearchOutput.where("(additional_info->>'moduleId')::int = ?", versions.pluck(:id)).empty?
      else
        versions.reject { |version| version.plans.empty? }.empty?
      end
    end

    #
    # CHANGES : Added module template support
    #
    def latest?
      id == if module?
              ::Template.latest_module_version(family_id).pluck('templates.id').first
            else
              ::Template.latest_version(family_id).pluck('templates.id').first
            end
    end
  end
end
