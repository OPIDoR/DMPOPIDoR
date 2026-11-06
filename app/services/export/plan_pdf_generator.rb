# frozen_string_literal: true

module Export
  # Service used to generate a pdf from a plan
  class PlanPdfGenerator
    def initialize(plan, user, selected_phases = nil, selected_research_outputs = nil, options = nil)
      @plan = plan
      @formatting = @plan.settings(:export).formatting
      @hash = @plan.as_pdf(user, true)
      @selected_phases = selected_phases
      @selected_research_outputs = selected_research_outputs
      @options = options || default_options
    end

    def call
      WickedPdf.new.pdf_from_string(
        html,
        enable_local_file_access: true,
        footer: {
          content: ApplicationController.render(
            template: 'shared/export/plan_footer',
            formats: [:html],
            layout: false,
            locals: { licence: license_details }
          ),
          spacing: 5
        }
      )
    end

    def base64
      Base64.strict_encode64(call)
    end

    def html
      @hash[:phases] = @hash[:phases].select { |p| @selected_phases.include?(p[:id].to_s) } if @selected_phases

      if @selected_research_outputs
        @hash[:research_outputs] = @hash[:research_outputs].order(display_order: :asc).select do |d|
          @selected_research_outputs.include?(d[:id].to_s)
        end
      end
      ApplicationController.render(
        partial: 'shared/export/plan',
        assigns: { plan: @plan, formatting: @formatting, hash: @hash, options: @options }
      )
    end

    private

    def license_details
      license = @plan.json_fragment.meta.license if @plan.structured?
      if license.present? && !license.data.compact.empty?
        return "#{license.data['licenseName']} (#{license.data['licenseUrl']})"
      end

      return unless @options[:public_plan]

      _("Copyright information: The above plan creator(s) have agreed that others may use as much of the text of this plan as they would like in their own plans, and customise it as necessary. You do not need to credit the creator(s) as the source of the language used, but using any of the plan's text does not imply that the creator(s) endorse, or have any relationship to, your project or proposal") # rubocop:disable Layout/LineLength
    end

    def default_options
      {
        show_coversheet: true,
        show_sections_questions: true,
        show_unanswered: true,
        show_custom_sections: true,
        show_research_outputs: true,
        public_plan: false
      }
    end
  end
end
