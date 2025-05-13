# frozen_string_literal: true

module Dmpopidor
  module Paginable
    # Customized code for Paginable PlansController
    module TemplatesController
      # GET /paginable/templates/modules/:page  (AJAX)
      # -----------------------------------------------------
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def modules
        authorize Template
        templates = Template.latest_module_version.where(customization_of: nil)
        case params[:f]
        when 'published'
          template_ids = templates.select { |t| t.published? || t.draft? }.collect(&:family_id)
          templates = Template.latest_version(template_ids)
        when 'unpublished'
          template_ids = templates.select { |t| !t.published? && !t.draft? }.collect(&:family_id)
          templates = Template.latest_version(template_ids)
        end
        paginable_renderise(
          partial: 'modules',
          scope: templates,
          query_params: { sort_field: 'templates.title', sort_direction: :asc },
          locals: { action: 'modules' },
          format: :json
        )
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    end
  end
end
