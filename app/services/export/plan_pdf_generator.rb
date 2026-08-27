# frozen_string_literal: true

module Export
  # Service used to generate a pdf from a plan
  class PlanPdfGenerator
    def initialize(plan, user, options = {})
      @plan = plan
      @formatting = @plan.settings(:export).formatting
      @hash = @plan.as_pdf(user, true)
      @options = options
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

    private

    def html
      ApplicationController.render(
        partial: 'shared/export/plan',
        assigns: { plan: @plan, formatting: @formatting, hash: @hash, options: @options }
      )
    end

    def license_details
      license = @plan.json_fragment.meta.license if @plan.structured?
      return unless license.present? && !license.data.compact.empty?

      "#{license.data['licenseName']} (#{license.data['licenseUrl']})"
    end
  end
end
