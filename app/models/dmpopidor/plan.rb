# frozen_string_literal: true

module Dmpopidor
  # rubocop:disable Metrics/ModuleLength
  # Customized code for Plan model
  module Plan
    include DynamicFormHelper

    # CHANGES : ADDED RESEARCH OUTPUT SUPPORT
    # rubocop:disable Metrics/AbcSize, Style/OptionalBooleanParameter
    # rubocop:disable Metrics/CyclomaticComplexity
    def answer(qid, create_if_missing = true, roid = nil)
      answer = answers.select { |a| a.question_id == qid && a.research_output_id == roid }
                      .max { |a, b| a.created_at <=> b.created_at }
      if answer.nil? && create_if_missing
        question           = ::Question.find(qid)
        answer             = Answer.new
        answer.plan_id     = id
        answer.question_id = qid
        answer.text        = question.default_value
        default_options    = []
        question.question_options.each do |option|
          default_options << option if option.is_default
        end
        answer.question_options = default_options
      end
      answer
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize, Style/OptionalBooleanParameter

    # CHANGES : Reviewer can be from a different org of the plan owner
    def reviewable_by?(user_id)
      reviewer = ::User.find(user_id)
      feedback_requested? &&
        reviewer.present? &&
        reviewer.can_review_plans?
    end

    # The number of research outputs for a plan.
    #
    # Returns Integer
    def num_research_outputs
      research_outputs.count
    end

    # Return the JSON Fragment linked to the Plan
    #
    # Returns JSON
    def json_fragment
      Fragment::Dmp.where("(data->>'plan_id')::int = ?", id).first
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_plan_fragments
      p '##########'
      p template.locale
      p '##########'
      template_locale = template.locale.eql?('en-GB') ? 'eng' : 'fra'
      # rubocop:disable Metrics/BlockLength
      I18n.with_locale template.locale do
        dmp_fragment = Fragment::Dmp.create!(
          data: {
            'plan_id' => id
          },
          madmp_schema: MadmpSchema.find_by(name: 'DMPStandard'),
          additional_info: {}
        )

        #################################
        # PERSON & CONTRIBUTORS FRAGMENTS
        #################################
        if owner.present?
          person = Fragment::Person.create!(
            data: {
              'nameType' => _('Personal'),
              'lastName' => owner.surname,
              'firstName' => owner.firstname,
              'mbox' => owner.email
            },
            dmp_id: dmp_fragment.id,
            madmp_schema: MadmpSchema.find_by(name: 'PersonStandard'),
            additional_info: { property_name: 'person' }
          )
        end

        dmp_coordinator = Fragment::Contributor.create!(
          data: {
            'person' => person.present? ? { 'dbid' => person.id } : nil,
            'role' => _('DMP manager')
          },
          dmp_id: dmp_fragment.id,
          parent_id: nil,
          madmp_schema: MadmpSchema.find_by(name: 'DMPCoordinator'),
          additional_info: { property_name: 'contact' }
        )

        project_coordinator = Fragment::Contributor.create!(
          data: {
            'person' => person.present? ? { 'dbid' => person.id } : nil,
            'role' => _('Project coordinator')
          },
          dmp_id: dmp_fragment.id,
          parent_id: nil,
          madmp_schema: MadmpSchema.find_by(name: 'PrincipalInvestigator'),
          additional_info: { property_name: 'principalInvestigator' }
        )

        #################################
        # META & PROJECT FRAGMENTS
        #################################

        project = Fragment::Project.create!(
          data: {
            'title' => title,
            'description' => description,
            'principalInvestigator' => { 'dbid' => project_coordinator.id }
          },
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: 'ProjectStandard'),
          additional_info: { property_name: 'project' }
        )
        project.instantiate

        meta = Fragment::Meta.create!(
          data: {
            'title' => format(_('"%{project_title}" project DMP'), project_title: title),
            'creationDate' => created_at.strftime('%F'),
            'lastModifiedDate' => updated_at.strftime('%F'),
            'dmpLanguage' => template_locale,
            'dmpId' => identifier,
            'contact' => { 'dbid' => dmp_coordinator.id }
          },
          dmp_id: dmp_fragment.id,
          parent_id: dmp_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: 'MetaStandard'),
          additional_info: { property_name: 'meta' }
        )
        meta.instantiate

        dmp_coordinator.update(parent_id: meta.id)
        project_coordinator.update(parent_id: project.id)
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def copy_plan_fragments(plan)
      create_plan_fragments if json_fragment.nil?

      incoming_dmp = plan.json_fragment
      raw_project = incoming_dmp.project.get_full_fragment
      raw_meta = incoming_dmp.meta.get_full_fragment
      raw_meta = raw_meta.merge(
        'title' => "Copy of #{raw_meta['title']}"
      )
      incoming_dmp.persons.each do |person|
        Fragment::Person.create(
          data: person.data,
          dmp_id: json_fragment.id,
          madmp_schema: MadmpSchema.find_by(name: 'PersonStandard'),
          additional_info: { property_name: 'person' }
        )
      end

      json_fragment.project.raw_import(raw_project, json_fragment.project.madmp_schema)
      json_fragment.meta.raw_import(raw_meta, json_fragment.meta.madmp_schema)
    end
    # rubocop:enable Metrics/AbcSize
  end
  # rubocop:enable Metrics/ModuleLength
end