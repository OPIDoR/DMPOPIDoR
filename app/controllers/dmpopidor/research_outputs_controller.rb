# frozen_string_literal: true

module Dmpopidor
  # Customized code for ResearchOutputsController
  # rubocop:disable Metrics/ModuleLength
  module ResearchOutputsController
    include Dmpopidor::ErrorHelper
    # GET /plans/:plan_id/research_outputs
    def index
      @plan = ::Plan.find(params[:plan_id])
      @research_outputs = @plan.research_outputs
      @persons = @plan.json_fragment.persons
      authorize @plan
      render('plans/research_outputs', locals: { plan: @plan, research_outputs: @research_outputs })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = format(_('There is no plan associated with id %{id}'), id: params[:id])
      redirect_to(controller: 'plans', action: 'index')
    end

    def show
      @research_output = ::ResearchOutput.find(params[:id])
      authorize @research_output

      render json: @research_output.serialize_json(true)
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def create
      authorize @plan
      I18n.with_locale @plan.template.locale do
        max_order = @plan.research_outputs.empty? ? 1 : @plan.research_outputs.maximum('display_order') + 1
        created_ro = @plan.research_outputs.create!(
          abbreviation: params[:abbreviation] || "#{_('RO')} #{max_order}",
          title: params[:title] || "#{_('Research output')} #{max_order}",
          output_type_description: params[:type],
          is_default: false,
          display_order: max_order
        )
        created_ro.create_json_fragments(params[:configuration])

        render json: {
          id: @plan.id,
          created_ro_id: created_ro.id,
          dmp_id: @plan.json_fragment.id,
          research_outputs: @plan.research_outputs.order(:display_order).map(&:serialize_json)
        }
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error(e.backtrace.join("\n"))
        internal_server_error(e.message)
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update
      @research_output = ::ResearchOutput.find(params[:id])
      plan =  @research_output.plan
      attrs = research_output_params

      authorize @research_output
      I18n.with_locale plan.template.locale do
        research_output_description = @research_output.json_fragment.research_output_description

        updated_data = research_output_description.data.merge({
                                                                title: params[:title],
                                                                type: params[:type],
                                                                containsPersonalData: params[:configuration][:hasPersonalData] ? _('Yes') : _('No') # rubocop:disable Layout/LineLength
                                                              })
        research_output_description.update(data: updated_data)
        research_output_description.update_research_output_parameters(true)
        PlanChannel.broadcast_to(plan, {
                                   target: 'dynamic_form',
                                   fragment_id: research_output_description.id,
                                   payload: research_output_description.get_full_fragment(with_ids: true)
                                 })

        research_outputs = ::ResearchOutput.where(plan_id: params[:plan_id])

        @research_output.update!(attrs)

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
      @research_output = ::ResearchOutput.find(params[:id])
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
    def import
      body = JSON.parse(request.body.string)
      research_output = ::ResearchOutput.find_by(uuid: body['uuid'])
      research_output_fragment = research_output.json_fragment

      authorize research_output

      target_plan = ::Plan.find(params[:plan_id])

      # rubocop:disable Metrics/BlockLength
      I18n.with_locale target_plan.template.locale do
        pos = target_plan.research_outputs.length + 1

        research_output_copy = target_plan.research_outputs.create!(
          abbreviation: "#{_('RO')} #{pos} [#{_('Copy of')} #{research_output.abbreviation}]",
          title: "#{_('Research output')} #{pos} [#{_('Copy of')} #{research_output.title}]",
          display_order: pos
        )

        # Creates the main ResearchOutput fragment
        research_output_copy_fragment = Fragment::ResearchOutput.create(
          data: {
            'research_output_id' => research_output_copy.id
          },
          madmp_schema: research_output_fragment.madmp_schema,
          dmp_id: target_plan.json_fragment.id,
          parent_id: target_plan.json_fragment.id,
          additional_info: research_output_fragment.additional_info
        )

        research_output.answers.each do |answer|
          answer_copy = ::Answer.deep_copy(answer)
          answer_copy.plan_id = target_plan.id
          answer_copy.research_output_id = research_output_copy.id
          answer_copy.save!
          MadmpFragment.deep_copy(answer.madmp_fragment, answer_copy.id, research_output_copy_fragment)
        end

        # module_id = research_output_copy_fragment.additional_info['moduleId']
        # template = module_id ? ::Template.find(module_id) : target_plan.template

        render json: {
          id: target_plan.id,
          created_ro_id: research_output_copy.id,
          dmp_id: target_plan.json_fragment.id,
          research_outputs: target_plan.research_outputs.order(:display_order).map(&:serialize_json)
        }
      end
      # rubocop:enable Metrics/BlockLength
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # DELETE AFTER V4 ?

    # rubocop:disable Metrics/AbcSize
    def create_remote
      @plan = ::Plan.includes(:template).find(params[:plan_id])
      I18n.with_locale @plan.template.locale do
        @persons = @plan.json_fragment.persons
        max_order = @plan.research_outputs.maximum('display_order') + 1

        registry_values = Registry.find_by(name: 'ResearchDataType').registry_values
        registry = registry_values.find { |entry| entry['data']['en_GB'] == 'Dataset' }

        created_ro = @plan.research_outputs.create(
          abbreviation: "#{_('RO')} #{max_order}",
          title: "#{_('Research output')} #{max_order}",
          is_default: false,
          display_order: max_order,
          output_type_description: registry['data'][@plan.template.locale.tr('-', '_')],
        )
        created_ro.create_json_fragments

        authorize @plan
        render json: {
          'html' => render_to_string(partial: 'research_outputs/list', locals: {
                                       plan: @plan,
                                       research_outputs: @plan.research_outputs,
                                       readonly: false
                                     })
        }
      end
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize
    def destroy_remote
      @plan = ::Plan.find(params[:plan_id])
      @research_output = ::ResearchOutput.find(params[:id])
      @persons = @plan.json_fragment.persons
      authorize @plan
      if @research_output.destroy
        flash[:notice] = success_message(@research_output, _('deleted'))
      else
        flash[:alert] = failure_message(@research_output, _('delete'))
      end
      redirect_to(action: 'index', plan_id: @plan.id)
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def update_remote
      @plan = ::Plan.find(params[:plan_id])
      @research_output = ::ResearchOutput.find(params[:id])
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
        render json: {
          'html' => render_to_string(partial: 'research_outputs/list', locals:
            {
              plan: @plan,
              research_outputs: @plan.research_outputs,
              readonly: false
            })
        }
      else
        flash[:alert] = failure_message(@research_output, _('update'))
        redirect_to(action: 'index')
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def sort
      @plan = ::Plan.find(params[:plan_id])
      authorize @plan
      params[:updated_order].each_with_index do |id, index|
        ::ResearchOutput.find(id).update(display_order: index + 1)
      end
      head :ok
    end

    def research_output_params
      params.require(:research_output)
            .permit(:id, :plan_id, :abbreviation, :title, :pid, :output_type_description, :contact_id)
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
