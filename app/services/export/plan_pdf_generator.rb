# frozen_string_literal: true

module Export
  # Service used to generate a pdf from a plan
  class PlanPdfGenerator
    def initialize(plan, user)
      @plan = plan
      @formatting = @plan.settings(:export).formatting
      @hash = @plan.as_pdf(user, true)
    end

    def call
      WickedPdf.new.pdf_from_string(
        html,
        margin: @formatting[:margin]
      )
    end

    def base64
      Base64.strict_encode64(call)
    end

    private

    def html
      ApplicationController.render(
        partial: 'shared/export/plan',
        assigns: { plan: @plan, formatting: @formatting, hash: @hash }
      )
    end
  end
end
