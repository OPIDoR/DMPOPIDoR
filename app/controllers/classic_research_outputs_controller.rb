# frozen_string_literal: true

# Controller to handle CRUD operations for the Research Outputs tab
class ClassicResearchOutputsController < ApplicationController
  helper ErrorHelper
  helper PaginableHelper

  before_action :fetch_plan, except: %i[show destroy]
  before_action :fetch_research_output, only: %i[edit update]

  after_action :verify_authorized

  # GET /plans/:plan_id/research_outputs
  def index
    @research_outputs = @plan.research_outputs
    @persons = @plan.json_fragment.persons
    authorize @research_outputs.first

    render 'research_outputs/index'
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = format(_('There is no plan associated with id %{id}'), id: params[:id])
    redirect_to(controller: 'plans', action: 'index')
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @plan = Plan.includes(:template).find(params[:plan_id])
    I18n.with_locale @plan.template.locale do
      @persons = @plan.json_fragment.persons
      max_order = @plan.research_outputs.maximum('display_order') + 1

      registry_values = Registry.find_by(name: 'ResearchDataType').values
      reg_val = registry_values.find { |entry| entry['en_GB'] == 'Dataset' }

      @research_output = @plan.research_outputs.create(
        abbreviation: "#{_('RO')} #{max_order}",
        title: "#{_('Research output')} #{max_order}",
        is_default: false,
        display_order: max_order,
        output_type_description: reg_val[@plan.template.locale.tr('-', '_')]
      )
      @research_output.create_json_fragments

      @research_outputs = @plan.research_outputs
      authorize @plan
      render turbo_stream: turbo_stream.append('research_outputs', partial: 'research_outputs/research_output',
                                                                   locals: { research_output: @research_output })
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def destroy
    @plan = Plan.find(params[:plan_id])
    @research_output = ResearchOutput.find(params[:id])
    @persons = @plan.json_fragment.persons
    authorize @plan
    if @research_output.destroy
      flash[:notice] = success_message(@research_output, _('deleted'))
    else
      flash[:alert] = failure_message(@research_output, _('delete'))
    end
    @research_outputs = @plan.research_outputs

    render turbo_stream: turbo_stream.remove(@research_output)
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    @plan = Plan.find(params[:plan_id])
    @research_output = ResearchOutput.find(params[:id])
    @persons = @plan.json_fragment.persons
    attrs = research_output_params
    contact_id = params[:contact_id]

    authorize @plan
    if @research_output.update(attrs)
      @research_output.create_json_fragments
      research_output_description = @research_output.json_fragment.research_output_description
      research_output_description.instantiate
      research_output_description.contact.update(
        data: {
          'person' => contact_id.present? ? { 'dbid' => contact_id } : nil,
          'role' => _('Data contact')
        }
      )
      render turbo_stream: turbo_stream.replace(@research_output, partial: 'research_outputs/research_output',
                                                                  locals: { research_output: @research_output })
    else
      flash[:alert] = failure_message(@research_output, _('update'))
      redirect_to(action: 'index')
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # GET /plans/:plan_id/research_outputs/:id/edit
  def edit
    @persons = @plan.json_fragment.persons
    authorize @research_output
    respond_to do |format|
      format.turbo_stream
      format.html { render partial: 'research_outputs/form', locals: { research_output: @research_output } }
    end
  end

  def sort
    @plan = Plan.find(params[:plan_id])
    authorize @plan
    params[:updated_order].each_with_index do |id, index|
      ResearchOutput.find(id).update(display_order: index + 1)
    end
    head :ok
  end

  private

  def output_params
    params.require(:research_output)
          .permit(%i[title abbreviation description output_type output_type_description
                     sensitive_data personal_data file_size file_size_unit mime_type_id
                     release_date access coverage_start coverage_end coverage_region
                     mandatory_attribution])
  end

  def research_output_params
    params.require(:research_output)
          .permit(:id, :plan_id, :abbreviation, :title, :pid, :output_type_description, :contact_id)
  end

  # =============
  # = Callbacks =
  # =============

  def fetch_plan
    @plan = Plan.find_by(id: params[:plan_id])
    return true if @plan.present?

    redirect_to root_path, alert: _('plan not found')
  end

  def fetch_research_output
    @research_output = ResearchOutput.find_by(id: params[:id])
    return true if @research_output.present? &&
                   @plan.research_outputs.include?(@research_output)

    redirect_to plan_research_outputs_path, alert: _('research output not found')
  end
end
