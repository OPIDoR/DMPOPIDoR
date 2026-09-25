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
      p '##################################'
      p @selected_phases
      p @selected_research_outputs
      p '##################################'
    end

    def call
      WickedPdf.new.pdf_from_string(
        html,
        margin: @formatting[:margin],
        footer:
             {
               center: license_details,
               font_size: 8,
               spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
               right: '[page] of [topage]',
               encoding: 'utf8'
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
      return unless license.present? && !license.data.compact.empty?

      "#{license.data['licenseName']} (#{license.data['licenseUrl']})"
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
