# frozen_string_literal: true

# Controller for the Plan Download page
class PlanExportsController < ApplicationController
  after_action :verify_authorized

  include ConditionsHelper

  # CHANGES:
  #   - Research outputs : added research output support with export mode
  #   - JSON export uses DMP OPIDoR JSON export (default & RDA)
  # --------------------------------
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def show
    @plan = ::Plan.includes(:answers, :research_outputs, {
                              template: { phases: { sections: :questions } }
                            }).find(params[:plan_id])

    if privately_authorized? && export_params[:form].present?
      skip_authorization
      @show_coversheet         = export_params[:project_details].present?
      @show_sections_questions = export_params[:question_headings].present?
      @show_unanswered         = export_params[:unanswered_questions].present?
      @show_complete_data      = export_params[:complete_data].present?
      @show_custom_sections    = export_params[:custom_sections].present?
      @show_research_outputs   = true
      @public_plan             = false

    elsif publicly_authorized?
      skip_authorization
      @show_coversheet         = true
      @show_sections_questions = true
      @show_unanswered         = true
      @show_custom_sections    = true
      @show_research_outputs   = true
      @public_plan             = true

    else
      raise Pundit::NotAuthorizedError
    end

    @hash           = @plan.as_pdf(current_user, @show_coversheet)
    @formatting     = export_params[:formatting] || @plan.settings(:export).formatting

    if params.key?(:selected_phases)
      @hash[:phases] = @hash[:phases].select { |p| params[:selected_phases].include?(p[:id].to_s) }
    end

    # Added contributors to coverage of plans.
    # Users will see both roles and contributor names if the role is filled
    # @hash[:data_curation] = Contributor.where(plan_id: @plan.id).data_curation
    # @hash[:investigation] = Contributor.where(plan_id: @plan.id).investigation
    # @hash[:pa] = Contributor.where(plan_id: @plan.id).project_administration
    # @hash[:other] = Contributor.where(plan_id: @plan.id).other

    if params.key?(:research_outputs)
      @hash[:research_outputs] = @hash[:research_outputs].order(display_order: :asc).select do |d|
        params[:research_outputs].include?(d[:id].to_s)
      end
    end

    respond_to do |format|
      format.html { show_html }
      format.csv  { show_csv }
      format.text { show_text }
      format.docx { show_docx }
      format.pdf  { show_pdf }
      format.json do
        selected_research_outputs = params[:research_outputs]&.map(&:to_i) || @plan.research_output_ids
        show_json(selected_research_outputs, params[:json_format])
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def show_html
    render layout: false
  end

  def show_csv
    send_data @plan.as_csv(current_user, @show_sections_questions,
                           @show_unanswered,
                           @selected_phase,
                           @show_custom_sections,
                           @show_coversheet,
                           @show_research_outputs),
              filename: "#{file_name}.csv"
  end

  def show_text
    send_data render_to_string(partial: 'shared/export/plan_txt'),
              filename: "#{file_name}.txt"
  end

  def show_docx
    # Using and optional locals_assign export_format
    render docx: "#{file_name}.docx",
           content: clean_html_for_docx_creation(render_to_string(partial: 'shared/export/plan',
                                                                  locals: { export_format: 'docx' }))
  end

  # CHANGES: PDF footer now displays DMP licence
  # rubocop:disable Metrics/AbcSize
  def show_pdf
    license = @plan.json_fragment.meta.license if @plan.structured?
    license_details = if license.present? && !license.data.compact.empty?
                        "#{license.data['licenseName']} (#{license.data['licenseUrl']})"
                      end
    render pdf: file_name,
           margin: @formatting[:margin],
           footer:
           {
             center: license_details,
             font_size: 8,
             spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
             right: '[page] of [topage]',
             encoding: 'utf8'
           }
  end
  # rubocop:enable Metrics/AbcSize

  # --------------------------------
  # Start DMP OPIDoR Customization
  # CHANGES: Changed JSON export to use madmp_fragments
  def show_json(selected_research_outputs, json_format)
    send_data render_to_string("shared/export/madmp_export_templates/#{json_format}/plan",
                               locals: {
                                 dmp: @plan.json_fragment,
                                 selected_research_outputs: selected_research_outputs
                               }), filename: "#{file_name}_#{json_format}.json"
  end

  def file_name
    # Sanitize bad characters and replace spaces with underscores
    ret = @plan.title
    ret = ret.strip.gsub(/\s+/, '_')
    ret = ret.delete('"')
    ret = ActiveStorage::Filename.new(ret).sanitized
    # limit the filename length to 100 chars. Windows systems have a MAX_PATH allowance
    # of 255 characters, so this should provide enough of the title to allow the user
    # to understand which DMP it is and still allow for the file to be saved to a deeply
    # nested directory
    ret[0, 100]
  end

  def publicly_authorized?
    PublicPagePolicy.new(current_user, @plan).plan_organisationally_exportable? ||
      PublicPagePolicy.new(current_user, @plan).plan_export?
  end

  def privately_authorized?
    if current_user.present?
      PlanPolicy.new(current_user, @plan).export?
    else
      false
    end
  end

  def export_params
    params.fetch(:export, {})
          .permit(:form, :project_details, :question_headings, :unanswered_questions, :complete_data,
                  :custom_sections, :research_outputs, :selected_phases,
                  formatting: [:font_face, :font_size, { margin: %i[top right bottom left] }])
  end

  # A method to deal with problematic text combinations
  # in html that break docx creation by htmltoword gem.
  def clean_html_for_docx_creation(html)
    # Replaces single backslash \ with \\ with gsub.
    html.gsub('\\', '\&\&')
  end
end
