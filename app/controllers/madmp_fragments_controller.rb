# frozen_string_literal: true

# Controller for the MadmpFragments, handle structures forms
class MadmpFragmentsController < ApplicationController
  after_action :verify_authorized
  include ErrorHelper

  def index
    research_output = ResearchOutput.find(params[:research_output_id])
    fragment = MadmpFragment.includes(:madmp_schema).find_by(parent_id: research_output.json_fragment.id,
                                                             classname: params[:classname])

    authorize fragment
    render json: {
      fragment_id: fragment.id,
      template_name: fragment.madmp_schema.name
    }
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    body = JSON.parse(request.body.string)
    dmp = Fragment::Dmp.find(body['dmp_id'])
    plan = dmp.plan
    research_output = body['research_output_id'] ? ResearchOutput.find(body['research_output_id']) : nil
    madmp_schema = MadmpSchema.find(body['schema_id'])
    defaults = madmp_schema.defaults(plan.template.locale)
    classname = madmp_schema.classname
    @fragment = MadmpFragment.new(
      data: {},
      parent_id: research_output.present? ? research_output.json_fragment.id : nil,
      dmp_id: dmp.id,
      madmp_schema: madmp_schema,
      classname:,
      additional_info: {
        'property_name' => madmp_schema.property_name_from_classname
      }
    )
    @fragment.classname = classname
    authorize @fragment
    unless classname.eql?('person')
      @fragment.answer = Answer.create!(
        research_output_id: research_output.id,
        plan_id: plan.id,
        question_id: body['question_id'],
        user_id: current_user.id
      )
    end
    @fragment.save!
    @fragment.handle_defaults(defaults)
    @fragment.import_with_instructions(body['data'], madmp_schema)

    render json: MadmpFragment.render_fragment_json(@fragment, madmp_schema)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def show
    @fragment = MadmpFragment.includes(:madmp_schema).find(params[:id])
    madmp_schema = @fragment.madmp_schema
    authorize @fragment
    render json: MadmpFragment.render_fragment_json(@fragment, madmp_schema)
  end

  # Needs some rework
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    @fragment = MadmpFragment.includes(:madmp_schema, :dmp, :parent).find(params[:id])
    form_data = JSON.parse(request.body.string)
    authorize @fragment

    MadmpFragment.transaction do
      @fragment.import_with_instructions(
        form_data,
        @fragment.madmp_schema
      )

      @fragment.update_meta_fragment
      @fragment.update_research_output_parameters unless %w[dmp project research_entity
                                                            meta].include?(@fragment.classname)

      render json: {
        fragment: @fragment.get_full_fragment(with_ids: true, with_template_name: true),
        meta_fragment: (if %w[dmp project research_entity].include?(@fragment.classname)
                          @fragment.dmp.meta.get_full_fragment(with_ids: true)
                        end)
      }.compact, status: :ok
    rescue ActiveRecord::StaleObjectError
      render json: {
        message: _('Error when saving form.')
      }, status: :internal_server_error
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def load_fragments
    @dmp_fragment = MadmpFragment.includes(:madmp_schema).find(params[:dmp_id])
    search_term = params[:term] || ''
    where_params = if params[:classname].present?
                     { classname: params[:classname] }
                   else
                     { madmp_schema_id: params[:schema_id] }
                   end
    fragment_list = MadmpFragment.includes(:madmp_schema).where(dmp_id: @dmp_fragment.id, **where_params)
    formatted_list = fragment_list.select { |f| f.to_s.downcase.include?(search_term) }
                                  .map do |f|
                                    {
                                      **f.get_full_fragment(with_ids: true),
                                      'label' => f.to_s
                                    }
                                  end
    authorize @dmp_fragment
    render json: {
      'results' => formatted_list
    }
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    @fragment = MadmpFragment.includes(:parent).find(params[:id])

    authorize @fragment
    if @fragment.destroy
      @fragment = success_message(@fragment, _('removed'))
      render json: { status: 200, message: 'Fragment removed successfully', fragment: @fragment }, status: :ok

    else
      @notice = failure_message(@fragment, _('remove'))
      render bad_request(@notice)
    end
  end

  def destroy_contributor
    @person = Fragment::Person.find(params[:contributor_id])
    contributors_list = @person.contributors

    authorize @person.becomes(MadmpFragment)
    if @person.destroy
      contributors_list.each(&:destroy)

      @person = success_message(@person, _('removed'))
      render json: { status: 200, message: 'Contributor removed successfully', fragment: @person }, status: :ok

    else
      @notice = failure_message(@person, _('remove'))
      render bad_request(@notice)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def import
    research_output = ResearchOutput.find(params[:research_output_id])
    research_output_fragment = research_output.json_fragment
    imported_fragment = MadmpFragment.includes(:madmp_schema).find(params[:madmp_fragment_id])

    authorize MadmpFragment.new(dmp_id: research_output_fragment.dmp_id)

    answer = Answer.find_or_initialize_by(question_id: params[:question_id],
                                          research_output_id: research_output.id)
    if answer.new_record?
      answer.plan_id = research_output.plan_id
      answer.user_id = current_user.id
      answer.save!

      MadmpFragment.deep_copy(imported_fragment, answer.id, research_output_fragment)
    else
      answer.madmp_fragment.raw_import(
        imported_fragment.get_full_fragment,
        imported_fragment.madmp_schema
      )
    end
    render json: MadmpFragment.render_fragment_json(answer.madmp_fragment, answer.madmp_fragment.madmp_schema)
  end
  # rubocop:enable Metrics/AbcSize

  # Since the StaleObjectError is triggered on the Answer we need to recover the
  # MadmpFragment data from the form, because the stale MadmpFragment has not yet been modified
  # This method takes the form data and remove every "sub fragment" data so it can be merged
  # to the real fragment data (with dbids)
  # rubocop:disable Metrics/AbcSize,  Metrics/CyclomaticComplexity
  def stale_data(form_data, schema)
    stale_data = {}
    form_data.each do |prop, content|
      schema_prop = schema.properties[prop]

      next if schema_prop&.dig('type').nil?
      next if schema_prop['type'].eql?('object') &&
              schema_prop['template_name'].present?
      next if schema_prop['type'].eql?('array') &&
              schema_prop['items']['template_name'].present?

      stale_data[prop] = content
    end
    stale_data
  end
  # rubocop:enable Metrics/AbcSize,  Metrics/CyclomaticComplexity

  def permitted_params
    permit_arr = [:id, :dmp_id, :parent_id, :schema_id, :source, :template_locale,
                  :property_name, :query_id,
                  {
                    answer: %i[id plan_id research_output_id question_id lock_version is_common]
                  }]
    params.require(:madmp_fragment).permit(permit_arr)
  end
end
