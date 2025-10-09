# frozen_string_literal: true

# Controller to handle CRUD operations for the Research Outputs tab
class ResearchOutputsController < ApplicationController
  include ErrorHelper

  helper PaginableHelper
  after_action :verify_authorized

  def show
    @research_output = ResearchOutput.includes(:answers,
                                               plan: { template: { phases: { sections: :questions } } })
                                     .find(params[:id])
    authorize @research_output

    render json: @research_output.serialize_json
  end

  # POST /plans/:plan_id/research_outputs
  # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  def create
    @plan = Plan.includes(:template, :research_outputs, :roles).find_by(id: params[:plan_id])
    language = Language.find_by(abbreviation: @plan.template.locale)
    attrs = research_output_params
    authorize ResearchOutput.new(plan: @plan)
    I18n.with_locale @plan.template.locale do
      max_order = @plan.research_outputs.empty? ? 1 : @plan.research_outputs.maximum('display_order') + 1
      created_ro = @plan.research_outputs.create!(
        abbreviation: attrs[:abbreviation] || "#{_('RO')} #{max_order}",
        title: attrs[:title] || "#{_('Research output')} #{max_order}",
        output_type_description: params[:type],
        topic: attrs[:topic] || 'generic',
        is_default: false, display_order: max_order
      )
      created_ro.create_json_fragments(params[:configuration])

      # pre-select owner org's guidance and the default org's guidance
      ids = (::Org.default_orgs.pluck(:id) << @plan.owner.org_id).flatten.uniq
      org_ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true, language_id: language.id)
      topic_ggs = if created_ro.topic.eql?('generic')
                    []
                  else
                    GuidanceGroup.where(Arel.sql("'#{created_ro.topic}' = ANY(topics) AND published=true AND language_id=#{language.id}"))
                  end

      created_ro.guidance_groups << org_ggs unless org_ggs.empty?
      created_ro.guidance_groups << topic_ggs unless topic_ggs.empty?

      render json: {
        id: @plan.id, created_ro_id: created_ro.id, dmp_id: @plan.json_fragment.id,
        research_outputs: @plan.research_outputs.order(:display_order).map(&:serialize_json)
      }
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error(e.message)
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

  # PATCH/PUT /plans/:plan_id/research_outputs/:id
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    @research_output = ResearchOutput.includes(plan: %i[template research_outputs]).find(params[:id])
    plan = @research_output.plan

    authorize @research_output
    I18n.with_locale plan.template.locale do
      research_outputs = ResearchOutput.where(plan_id: params[:plan_id])

      @research_output.update!(
        abbreviation: params[:abbreviation],
        title: params[:title],
        output_type_description: params[:type]
      )
      research_output_description = @research_output.update_description(
        contains_personal_data: params[:configuration][:hasPersonalData]
      )
      PlanChannel.broadcast_to(plan, {
                                 target: 'dynamic_form',
                                 fragment_id: research_output_description.id,
                                 payload: research_output_description.get_full_fragment(with_ids: true)
                               })

      render json: {
               status: 200,
               message: 'Research output updated',
               research_outputs: research_outputs.order(:display_order).map(&:serialize_json)
             },
             status: :ok
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error(e.message)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def destroy
    @research_output = ResearchOutput.find(params[:id])
    research_output_fragment = @research_output.json_fragment
    plan = @research_output.plan
    authorize @research_output
    if @research_output.destroy
      research_output_fragment.destroy!
      render json: {
        id: plan.id,
        dmp_id: plan.json_fragment.id,
        research_outputs: plan.research_outputs.order(:display_order).map(&:serialize_json)
      }
    else
      render json: {
        'error' => failure_message(@research_output, _('delete'))
      }, status: 500
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  def import
    body = JSON.parse(request.body.string)
    research_output = ResearchOutput.find_by(uuid: body['uuid'])
    research_output_fragment = research_output.json_fragment
    data_type = research_output_fragment.additional_info['dataType']
    duplicate = body['duplicate']

    authorize research_output

    target_plan = ::Plan.includes(:template).find(params[:plan_id])

    I18n.with_locale target_plan.template.locale do # rubocop:disable Metrics/BlockLength
      pos = target_plan.research_outputs.length + 1

      prefix_text = duplicate ? _('Copy of') : _('Import of')

      research_output_copy = target_plan.research_outputs.create!(
        abbreviation: "#{_('RO')} #{pos} [#{prefix_text} #{research_output.abbreviation}]",
        title: "#{_('Research output')} #{pos} [#{prefix_text} #{research_output.title}]",
        display_order: pos,
        output_type_description: research_output.output_type_description,
        output_type: research_output.output_type
      )

      module_tplt = Template.module(data_type:, locale: target_plan.template.locale)

      # Creates the main ResearchOutput fragment
      research_output_copy_fragment = Fragment::ResearchOutput.create(
        data: {
          'research_output_id' => research_output_copy.id
        },
        madmp_schema: research_output_copy_fragment.madmp_schema,
        dmp_id: target_plan.json_fragment.id,
        parent_id: target_plan.json_fragment.id,
        additional_info: research_output_copy_fragment.additional_info.merge(
          'moduleId' => module_tplt&.id
        )
      )

      template = module_tplt || target_plan.template

      Import::PlanImportService.import_research_output(
        research_output_copy_fragment,
        research_output_copy.json_fragment.get_full_fragment,
        target_plan,
        template
      )
      research_output_copy.update_description

      # If the RO is duplicated through the UI, copy the guidance groups associated to the target RO
      if duplicate
        research_output.guidance_groups.each do |guidance_group|
          research_output_copy.guidance_groups << guidance_group if guidance_group.present?
        end
      end

      render json: {
        id: target_plan.id,
        created_ro_id: research_output_copy.id,
        dmp_id: target_plan.json_fragment.id,
        research_outputs: target_plan.research_outputs.order(:display_order).map(&:serialize_json)
      }
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def has_guidances # rubocop:disable Naming/PredicatePrefix
    research_output = ResearchOutput.includes(:themes).find(params[:id])
    authorize research_output
    question = Question.includes(:annotations, :themes).find(params[:question])
    has_guidances = if question.annotations.where(type: 'guidance').any?
                      true
                    elsif research_output.guidance_groups.any?
                      research_output.theme_ids.intersect?(question.theme_ids.uniq)
                    else
                      false
                    end
    render json: {
      has_guidances:
    }, status: :ok
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def question_guidances
    ro_id = params[:id]
    unless ro_id&.to_i&.positive?
      bad_request("Research output [#{ro_id}] id, must be present or positive value")
      return
    end

    question_id = params[:question]
    unless question_id&.to_i&.positive?
      bad_request("Question [#{question_id}] id, must be present or positive value")
      return
    end

    begin
      @research_output = ResearchOutput.includes(plan: [:template]).find(ro_id)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Research output [#{ro_id}] not found")
      Rails.logger.error(e.backtrace.join("\n"))
      not_found('No research output found')
      return
    rescue StandardError => e
      Rails.logger.error('An error occured during retriving research output data')
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error(e.message)
      return
    end

    begin
      authorize @research_output
    rescue Pundit::NotAuthorizedError => e
      Rails.logger.error('An error occurred while checking authorisations')
      Rails.logger.error(e.backtrace.join("\n"))
      forbidden
      return
    end

    begin
      question = Question.includes(:themes).find(question_id)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Question [#{plan_id}] not found")
      Rails.logger.error(e.backtrace.join("\n"))
      not_found('No plan found')
      return
    rescue StandardError => e
      Rails.logger.error('An error occured during retriving question data')
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error(e.message)
      return
    end

    begin
      guidance_presenter = GuidancePresenter.new(@research_output)
      guidances = guidance_presenter.tablist(question)
    rescue StandardError => e
      Rails.logger.error('Cannot create guidance presenter')
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error('An error occured during guidance presenter creation')
      return
    end

    guidances = guidances.map do |guidance|
      {
        name: guidance[:name],
        groups: guidance[:groups].to_a,
        annotations: guidance[:annotations]
      }
    end

    render json: {
             status: 200, message: "Guidances for research output [#{ro_id}] and question [#{question_id}]",
             guidances: guidances
           },
           status: :ok
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def guidance_groups
    @all_ggs_grouped_by_org = get_guidances_groups(params[:id])
    render json: {
      status: 200,
      message: 'Guidance groups',
      data: @all_ggs_grouped_by_org
    }, status: :ok
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def select_guidance_groups
    @research_output = ResearchOutput.includes(:guidance_groups, plan: [:template]).find(params[:id])
    authorize @research_output

    body = JSON.parse(request.raw_post)

    selected_ids = body['guidance_group_ids']

    guidance_group_ids = if selected_ids.blank?
                           []
                         else
                           selected_ids.map(&:to_i).uniq
                         end

    @research_output.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)

    if @research_output.save
      @all_ggs_grouped_by_org = get_guidances_groups(params[:id])
      render json: {
        status: 200,
        message: "Guidances updated for plan [#{params[:id]}]",
        guidance_groups: @all_ggs_grouped_by_org
      }, status: :ok
    else
      Rails.logger.error("Plan [#{params[:id]}] not updated")
      internal_server_error("Plan [#{params[:id]}] not updated")
    end
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Plan [#{params[:id]}] not found")
    not_found("Plan [#{params[:id]}] not found")
  rescue JSON::ParserError, TypeError
    Rails.logger.error('Bad request - Invalid JSON data')
    bad_request('Bad request - Invalid JSON data')
  rescue StandardError => e
    Rails.logger.error("Internal server error - #{e.message}")
    internal_server_error("Internal server error - #{e.message}")
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def research_output_params
    params.require(:research_output)
          .permit(:id, :plan_id, :abbreviation, :title, :type, :contact_id, :topic,
                  configuration: {})
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def get_guidances_groups(id)
    @research_output = ResearchOutput.includes(
      :guidance_groups, plan: [template: [:phases]]
    ).find(id)
    research_output_fragment = @research_output.json_fragment
    data_type = research_output_fragment.additional_info['dataType']
    @plan = @research_output.plan
    authorize @research_output
    current_locale = Language.where(abbreviation: @plan.template.locale).first

    @all_guidance_groups = GuidanceGroup.published.includes(:org).where(
      Arel.sql("'#{data_type}' = ANY(data_types) AND language_id = #{current_locale.id}")
    )
    @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)
    @selected_guidance_groups = @research_output.guidance_groups.ids.to_set

    @default_orgs = Org.default_orgs

    @all_ggs_grouped_by_org.map do |key, group|
      {
        name: key.name,
        id: key.id,
        important: @default_orgs.include?(key) || group.any? { |item| @selected_guidance_groups.include?(item.id) },
        guidance_groups: group.map do |item|
          {
            id: item.id,
            name: item.name,
            selected: @selected_guidance_groups.include?(item.id),
            description: item.description,
            language_id: item.language_id,
            topics: item.topics
          }
        end
      }
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
