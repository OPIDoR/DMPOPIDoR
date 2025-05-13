# frozen_string_literal: true

module Dmpopidor
  module OrgAdmin
    # Customized code for OrgAdmin QuestionsController
    module QuestionsController
      # GET /org_admin/templates/[:template_id]/phases/[:phase_id]/sections/[:id]/questions/[:question_id]/edit
      # CHANGES : Added  MadmpSchema list
      # rubocop:disable Metrics/AbcSize
      def edit
        question = Question.includes(:annotations,
                                     :question_options,
                                     section: { phase: :template })
                           .find(params[:id])
        template = question.section.phase.template
        @available_classnames = Settings::Question::AVAILABLE_CLASSNAMES[template.data_type]
        @madmp_schemas = MadmpSchema.where(classname: @available_classnames, data_type: template.data_type)
        @available_themes = Theme.where(data_type: template.data_type).order('title')
        authorize question
        render json: { html: render_to_string(partial: 'edit', locals: {
                                                template: template,
                                                section: question.section,
                                                question: question,
                                                question_formats: allowed_question_formats,
                                                conditions: question.conditions
                                              }) }
      end
      # rubocop:enable Metrics/AbcSize

      # SEE MODULE
      # GET /org_admin/templates/:template_id/phases/:phase_id/sections/:section_id/questions/new
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # CHANGES : Added  MadmpSchema list
      def new
        section = Section.includes(:questions, phase: :template).find(params[:section_id])
        template = section.phase.template
        nbr = section.questions.maximum(:number)
        question_format = QuestionFormat.find_by(title: 'Text area')
        question = Question.new(section_id: section.id,
                                question_format: question_format,
                                number: nbr.present? ? nbr + 1 : 1)
        question_formats = allowed_question_formats
        @available_classnames = Settings::Question::AVAILABLE_CLASSNAMES[template.data_type]
        @madmp_schemas = MadmpSchema.where(classname: @available_classnames, data_type: template.data_type)
        @available_themes = Theme.where(data_type: template.data_type).order('title')
        authorize question
        render json: { html: render_to_string(partial: 'form', locals: {
                                                template: template,
                                                section: section,
                                                question: question,
                                                method: 'post',
                                                url: if template&.module?
                                                       super_admin_template_phase_section_questions_path(
                                                         template_id: template.id,
                                                         phase_id: section.phase.id,
                                                         id: section.id
                                                       )
                                                     else
                                                       org_admin_template_phase_section_questions_path(
                                                         template_id: template.id,
                                                         phase_id: section.phase.id,
                                                         id: section.id
                                                       )
                                                     end,
                                                question_formats: question_formats
                                              }) }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
