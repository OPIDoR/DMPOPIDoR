# frozen_string_literal: true

# Controller for the Write plan and create plan pages
# rubocop:disable Metrics/ClassLength
class PlansController < ApplicationController
  include ConditionalUserMailer
  include OrgSelectable

  helper ErrorHelper
  helper PaginableHelper
  helper SettingsTemplateHelper

  after_action :verify_authorized, except: [:overview]

  # GET /plans
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def index
    authorize Plan
    @plans = if request.format.json?
               Plan.includes(:roles).owner_or_coowner(current_user)
                   .where.not(visibility: Plan.visibilities[:is_test])
             else
               Plan.includes(:roles, api_client_roles: :api_client).active(current_user)
             end
    @organisationally_or_publicly_visible = if current_user.org.is_other?
                                              []
                                            else
                                              Plan.organisationally_or_publicly_visible(current_user)
                                            end
    respond_to do |format|
      format.html
      format.json do
        # plans = @plans.zip(@organisationally_or_publicly_visible).flatten.compact
        plans = @plans.order('updated_at desc').filter(&:structured?).compact
        plans = plans.map do |plan|
          {
            id: plan.id,
            title: plan.title,
            research_outputs: plan.research_outputs
          }
        end.reject do |plan| # rubocop:disable Style/MultilineBlockChain
          plan[:research_outputs].empty? ||
            plan[:research_outputs].all? { |output| output[:title].nil? || output[:title].strip.empty? } ||
            plan[:research_outputs].all? do |output|
              output[:output_type].nil? || output[:output_type].strip.empty?
            end
        end
        render json: { plans: plans }
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # CHANGES:
  # - Emptied method as logic is now handled by ReactJS
  def new
    authorize Plan.new
    respond_to :html
  end

  # POST /plans
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    @plan = Plan.new
    authorize @plan
    # If the template_id is blank then we need to look up the available templates and
    # return JSON
    if plan_params[:template_id].blank?
      render json: {
        message: _('Unable to identify a suitable template for your plan.')
      }, status: 400
    else
      @plan.template = Template.find(plan_params[:template_id])
      # rubocop:disable Metrics/BlockLength
      I18n.with_locale @plan.template.locale do
        @plan.visibility = Rails.configuration.x.plans.default_visibility

        @plan.template = Template.find(plan_params[:template_id])

        @plan.org = current_user.org

        @plan.title = if current_user.firstname.blank?
                        format(_('My Plan (%{title})'), title: @plan.template.title)
                      else
                        format(_("%{user_name}'s Plan"), user_name: current_user.firstname)
                      end
        if @plan.save
          # pre-select org's guidance and the default org's guidance
          ids = (::Org.default_orgs.pluck(:id) << current_user.org_id).flatten.uniq

          language = Language.find_by(abbreviation: @plan.template.locale)

          ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true, language_id: language.id)

          @plan.guidance_groups << ggs unless ggs.empty?

          default = Template.default

          msg = "#{success_message(@plan, _('created'))}<br />"

          if !default.nil? && default == @plan.template
            # We used the generic/default template
            msg += " #{_('This plan is based on the default template.')}"

          elsif !@plan.template.customization_of.nil?
            # We used a customized version of the the funder template
            # rubocop:disable Layout/LineLength
            msg += " #{_('This plan is based on the')} #{@plan.funder&.name}: '#{@plan.template.title}' #{_('template with customisations by the')} #{@plan.template.org.name}"
            # rubocop:enable Layout/LineLength
          else
            # We used the specified org's or funder's template
            msg += format(_('This plan is based on the "%{template_title}" template provided by %{org_name}.'),
                          template_title: @plan.template.title, org_name: @plan.template.org.name)
          end

          @plan.add_user!(current_user.id, :creator)
          @plan.save
          # Initialize Meta & Project
          @plan.create_plan_fragments

          registry_values = Registry.find_by(name: 'ResearchDataType').values
          reg_val = registry_values.find { |entry| entry['en_GB'] == 'Dataset' }

          # Add default research output if possible
          if @plan.structured? == false
            created_ro = @plan.research_outputs.create!(
              abbreviation: "#{_('RO')} 1",
              title: "#{_('Research output')} 1",
              is_default: true,
              display_order: 1,
              output_type_description: reg_val[@plan.template.locale.tr('-', '_')]
            )
            created_ro.create_json_fragments({ hasPersonalData: true })
          end

          flash[:notice] = msg
          render json: {
            id: @plan.id
          }, status: 200

        else
          # Something went wrong so report the issue to the user
          render json: {
            message: failure_message(@plan, _('create'))
          }, status: 400
        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # GET /plans/show
  # CHANGES:
  # - Kept only necessary code as logic is now handled by ReactJS
  def show
    @plan = Plan.includes(
      template: [:phases]
    ).find(params[:id])
    authorize @plan

    @visibility = if @plan.visibility.present?
                    @plan.visibility.to_s
                  else
                    Rails.configuration.x.plans.default_visibility
                  end

    respond_to :html
  end

  # TODO: This feels like it belongs on a phases controller, perhaps introducing
  #       a non-namespaces phases_controller woulld make sense here. Consider
  #       doing this when we refactor the Plan editing UI
  # GET /plans/:plan_id/phases/:id/edit
  # rubocop:disable Metrics/AbcSize
  def edit
    plan = Plan.includes(
      { template: {
        phases: {
          sections: {
            questions: %i[question_format annotations madmp_schema]
          }
        }
      } },
      { answers: :notes }
    )
               .find(params[:id])
    authorize plan
    phase_id = params[:phase_id].to_i
    phase = plan.template.phases.find { |p| p.id == phase_id }
    raise ActiveRecord::RecordNotFound if phase.nil?

    guidance_groups = GuidanceGroup.where(published: true, id: plan.guidance_group_ids)
    render_phases_edit(plan, phase, guidance_groups)
  end
  # rubocop:enable Metrics/AbcSize

  def structured_edit
    plan = Plan.includes(
      { template: :phases }
    )
               .find(params[:id])
    authorize plan
    template = plan.template
    render('/phases/edit', locals:
      {
        plan:,
        template:,
        locale: template.locale
      })
  end

  # PUT /plans/1
  # rubocop:disable Metrics/MethodLength
  def update
    @plan = Plan.find(params[:id])
    authorize @plan
    # rubocop:disable Metrics/BlockLength
    respond_to do |format|
      # TODO: See notes below on the pan_params definition. We should refactor
      #       this once the UI pages have been reworked
      # Save the guidance group selections
      guidance_group_ids = if params[:guidance_group_ids].blank?
                             []
                           else
                             params[:guidance_group_ids].map(&:to_i).uniq
                           end
      @plan.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)

      if @plan.save # _attributes(attrs)
        format.html do
          redirect_to plan_path(@plan),
                      notice: success_message(@plan, _('saved'))
        end
        format.json do
          render json: { code: 1, msg: success_message(@plan, _('saved')) }
        end
      else
        format.html do
          # TODO: Should do a `render :show` here instead but show defines too many
          #       instance variables in the controller
          redirect_to plan_path(@plan).to_s, alert: failure_message(@plan, _('save'))
        end
        format.json do
          render json: { code: 0, msg: failure_message(@plan, _('save')) }
        end
      end
    rescue StandardError => e
      flash[:alert] = failure_message(@plan, _('save'))
      format.html do
        Rails.logger.error "Unable to save plan #{@plan&.id} - #{e.message}"
        redirect_to plan_path(@plan).to_s, alert: failure_message(@plan, _('save'))
      end
      format.json do
        render json: { code: 0, msg: flash[:alert] }
      end
    end
    # rubocop:enable Metrics/BlockLength
  end

  # rubocop:enable Metrics/MethodLength

  # GET /plans/:id/budget
  def budget
    @plan = Plan.find(params[:id])
    dmp_fragment = @plan.json_fragment
    @costs = Fragment::Cost.where(dmp_id: dmp_fragment.id)
    authorize @plan
    render(:budget, locals: { plan: @plan, costs: @costs })
  end

  # GET /plans/:id/share
  def share
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      @plan_roles = @plan.roles.where(active: true)
      # --------------------------------
      # Start DMP OPIDoR Customization
      # --------------------------------
      @plan_client_roles = @plan.api_client_roles
      @api_clients = ApiClient.all.select do |client|
        client.org&.funder?
      end
      # --------------------------------
      # End DMP OPIDoR Customization
      # --------------------------------
    else
      redirect_to(plans_path)
    end
  end

  # TODO: Does this belong on the Roles or FeedbackRequest controllers
  #       as a PUT verb?
  # GET /plans/:id/request_feedback
  def request_feedback
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      @plan_roles = @plan.roles.where(active: true)
    else
      redirect_to(plans_path)
    end
  end

  # DELETE /plans/:id
  # rubocop:disable Metrics/AbcSize
  def destroy
    @plan = Plan.find(params[:id])
    authorize @plan
    if @plan.destroy
      # --------------------------------
      # Start DMP OPIDoR Customization
      # Changes : Destroying the plan should destroy the associated madmp_fragments
      # --------------------------------
      dmp_fragment = @plan.json_fragment
      dmp_fragment.destroy
      # --------------------------------
      # End DMP OPIDoR Customization
      # --------------------------------
      respond_to do |format|
        format.html do
          redirect_to plans_url,
                      notice: success_message(@plan, _('deleted'))
        end
      end
    else
      respond_to do |format|
        flash[:alert] = failure_message(@plan, _('delete'))
        format.html { render action: 'edit' }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # TODO: Is this used? It seems like it belongs on the answers controller
  # GET /plans/:id/answer
  # rubocop:disable Metrics/AbcSize
  def answer
    @plan = Plan.find(params[:id])
    authorize @plan
    if params[:q_id].nil?
      respond_to do |format|
        format.json { render json: {} }
      end
    else
      respond_to do |format|
        format.json do
          render json: @plan.answer(params[:q_id], false).to_json(include: :options)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # GET /plans/:id/download
  def download
    @plan = Plan.find(params[:id])
    authorize @plan

    # --------------------------------
    # Start DMP OPIDoR Customization
    # --------------------------------
    @research_outputs = @plan.research_outputs
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------

    @phase_options = @plan.phases.order(:number).pluck(:title, :id)
    @phase_options.insert(0, ['All phases', 'All']) if @phase_options.length > 1
    @export_settings = @plan.settings(:export)
    render 'download'
  end

  # POST /plans/:id/duplicate
  # rubocop:disable Metrics/AbcSize
  def duplicate
    plan = Plan.find(params[:id])
    authorize plan
    @plan = plan.structured?.eql?(true) ? Plan.structured_deep_copy(plan) : Plan.deep_copy(plan)
    respond_to do |format|
      if @plan.save
        @plan.add_user!(current_user.id, :creator)
        format.html { redirect_to @plan, notice: success_message(@plan, _('copied')) }
      else
        format.html { redirect_to plans_path, alert: failure_message(@plan, _('copy')) }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # TODO: This should probablly just be merged with the update route
  # POST /plans/:id/visibility
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def visibility
    plan = Plan.find(params[:id])
    if plan.present?
      authorize plan
      if plan.visibility_allowed?
        plan.visibility = plan_params[:visibility]
        if plan.save
          deliver_if(recipients: plan.owner_and_coowners,
                     key: 'owners_and_coowners.visibility_changed') do |r|
            UserMailer.plan_visibility(r, plan).deliver_now
          end
          render status: :ok,
                 json: { msg: success_message(plan, _('updated')) }
        else
          render status: :internal_server_error,
                 json: { msg: failure_message(plan, _('update')) }
        end
      else
        # rubocop:disable Layout/LineLength
        render status: :forbidden, json: {
          msg: format(_("Unable to change the plan's status since it is needed at least %{percentage} percentage responded"), percentage: Rails.configuration.x.plans.default_percentage_answered)
        }
        # rubocop:enable Layout/LineLength
      end
    else
      render status: :not_found,
             json: { msg: format(_('Unable to find plan id %{plan_id}'),
                                 plan_id: params[:id]) }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # TODO: This should probablly just be merged with the update route
  # POST /plans/:id/set_test
  def set_test
    plan = Plan.find(params[:id])
    authorize plan
    plan.visibility = (params[:is_test] == '1' ? :is_test : :privately_visible)
    if plan.save
      render json: {
        code: 1,
        msg: (plan.is_test? ? _('Your project is now a test.') : _('Your project is no longer a test.'))
      }
    else
      render status: :bad_request, json: {
        code: 0, msg: _("Unable to change the plan's test status")
      }
    end
  end

  # GET /plans/:id/overview
  def overview
    plan = Plan.includes(template: [:org, { phases: { sections: :questions } }])
               .find(params[:id])

    authorize plan
    render(:overview, locals: { plan: plan })
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = format(_('There is no plan associated with id %{id}'), id: params[:id])
    redirect_to(action: :index)
  end

  def guidance_groups
    @all_ggs_grouped_by_org = get_guidances_groups(params[:id])
    render json: {
      status: 200,
      message: 'Guidance groups',
      data: @all_ggs_grouped_by_org
    }, status: :ok
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def select_guidance_groups
    @plan = Plan.find(params[:id])
    template = @plan.template
    authorize @plan

    body = JSON.parse(request.raw_post)
    if body['ro_id'].present?
      research_output = ResearchOutput.find(body['ro_id'])
      module_id = research_output.json_fragment.additional_info['moduleId']
      template = module_id ? Template.find(module_id) : @plan.template
    end

    selected_ids = body['guidance_group_ids']

    guidance_group_ids = if selected_ids.blank?
                           []
                         else
                           selected_ids.map(&:to_i).uniq
                         end

    @plan.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)

    guidance_presenter = GuidancePresenter.new(@plan)

    if @plan.save
      @all_ggs_grouped_by_org = get_guidances_groups(params[:id])
      render json: {
        status: 200,
        message: "Guidances updated for plan [#{params[:id]}]",
        guidance_groups: @all_ggs_grouped_by_org,
        questions_with_guidance: template.questions.select do |q|
          question = Question.find(q.id)
          guidance_presenter.any?(question:)
        end.pluck(:id)
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
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def question_guidances
    plan_id = params[:id]
    unless plan_id&.to_i&.positive?
      bad_request("Plan [#{plan_id}] id, must be present or positive value")
      return
    end

    question_id = params[:question]
    unless question_id&.to_i&.positive?
      bad_request("Question [#{question_id}] id, must be present or positive value")
      return
    end

    begin
      @plan = Plan.find(plan_id)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error("Plan [#{plan_id}] not found")
      Rails.logger.error(e.backtrace.join("\n"))
      not_found('No plan found')
      return
    rescue StandardError => e
      Rails.logger.error('An error occured during retriving plan data')
      Rails.logger.error(e.backtrace.join("\n"))
      internal_server_error(e.message)
      return
    end

    begin
      authorize @plan
    rescue Pundit::NotAuthorizedError => e
      Rails.logger.error('An error occurred while checking authorisations')
      Rails.logger.error(e.backtrace.join("\n"))
      forbidden
      return
    end

    begin
      question = Question.find(question_id)
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
      guidance_presenter = GuidancePresenter.new(@plan)
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
             status: 200, message: "Guidances for plan [#{plan_id}] and question [#{question_id}]",
             guidances: guidances
           },
           status: :ok
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def import_plan
    @plan = Plan.new
    authorize @plan
    begin
      plan_importer = Import::Plan.new
      data = plan_importer.import(@plan, import_params, current_user)

      render json: { status: 201, message: _('imported'), data: data }, status: :created
    rescue IOError
      bad_request(_('Unvalid file'))
    rescue JSON::ParserError
      bad_request(_('File should contain JSON'))
    rescue StandardError => e
      Rails.logger.error e.backtrace
      bad_request("#{_('An error has occured: ')} #{e.message}")
    end
  end
  # rubocop:enable Metrics/AbcSize

  def research_outputs_data
    plan = Plan.find(params[:id])
    authorize plan

    render json: {
      id: plan.id,
      dmp_id: plan.json_fragment.id,
      template: plan.template.serialize_json,
      research_outputs: plan.research_outputs.order(:display_order).map(&:serialize_json)
    }
  end

  # GET AJAX /plans/:id/contributors_data
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def contributors_data
    plan = Plan.find(params[:id])
    authorize plan

    dmp_fragment = plan.json_fragment
    contributors = dmp_fragment.persons.order(
      Arel.sql("data->>'lastName', data->>'firstName'")
    )
    schema = MadmpSchema.find_by(name: 'PersonStandard')
    render json: {
      dmp_id: plan.json_fragment.id,
      contributors: contributors.map do |contributor|
        {
          id: contributor.id,
          data: contributor.get_full_fragment(with_ids: true),
          roles: contributor.roles(include_ro_names: true)
        }
      end,
      template: {
        id: schema.id,
        schema: schema.schema
      }
    }
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # ============================
  # = Private instance methods =
  # ============================

  private

  # --------------------------------
  # Start DMP OPIDoR Customization
  # SEE app/controllers/dmpopidor/plans_controller.rb
  # Changes : Removed everything except guidances group info. The rest of the info is
  # handled by MadmpFragmentController
  # --------------------------------
  def plan_params
    # TODO: The guidance_group_ids setup on the form is a bit convoluted. Refactor
    #       it once we've started updating the UI for these pages. There should
    #       probably be a separate controller and set the checkboxes to use `remote: true`
    params.require(:plan)
          .permit(:template_id, :title, :visibility, :description, :identifier,
                  :start_date, :end_date, :org_id, :org_name, :org_crosswalk,
                  :ethical_issues, :ethical_issues_description, :ethical_issues_report,
                  :funding_status,
                  grant: %i[name value],
                  org: %i[id org_id org_name org_sources org_crosswalk],
                  funder: %i[id org_id org_name org_sources org_crosswalk])
  end

  def import_params
    params.require(:import)
          .permit(:format, :template_id, :json_file)
  end

  def import_errors(errs)
    msg = "#{_('Invalid JSON: ')} <ul>"
    errs.each do |err|
      msg += "<li>#{err}</li>"
    end
    msg += '</ul>'
    msg
  end

  # Get the parameters corresponding to the schema
  def schema_params(schema, form_prefix, flat: false)
    s_params = schema.generate_strong_params(flat: flat)
    params.require(:plan)[form_prefix].permit(s_params)
  end

  # different versions of the same template have the same family_id
  # but different version numbers so for each set of templates with the
  # same family_id choose the highest version number.
  def get_most_recent(templates)
    groups = {}
    templates.each do |t|
      k = t.family_id
      if groups.key?(k)
        other = groups[k]
        groups[k] = t if other.version < t.version
      else
        groups[k] = t
      end
    end
    groups.values
  end

  # find all object under src_plan_key
  # merge them into the items under obj_plan_key using
  # super_id = id
  # so we have answers which each have a question_id
  # rollup(plan, "answers", "quesiton_id", "questions")
  # will put the answers into the right questions.
  def rollup(plan, src_plan_key, super_id, obj_plan_key)
    id_to_obj = {}
    plan[src_plan_key].each do |o|
      id = o[super_id]
      id_to_obj[id] = [] unless id_to_obj.key?(id)
      id_to_obj[id] << o
    end

    plan[obj_plan_key].each do |o|
      id = o['id']
      o[src_plan_key] = id_to_obj[id] if id_to_obj.key?(id)
    end
    plan.delete(src_plan_key)
  end

  # CHANGES : maDMP Fragments SUPPORT
  def render_phases_edit(plan, phase, guidance_groups)
    readonly = !plan.editable_by?(current_user.id)
    @schemas = MadmpSchema.all
    # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
    # we create a hash whose keys are question id and value is the answer associated
    answers = plan.answers
                  .includes(:madmp_fragment)
                  .each_with_object({}) { |a, m| m["#{a.question_id}_#{a.research_output_id}"] = a }
    render('/phases/edit', locals: {
             base_template_org: phase.template.base_org,
             plan: plan,
             phase: phase,
             readonly: readonly,
             guidance_groups: guidance_groups,
             answers: answers,
             guidance_presenter: GuidancePresenter.new(plan)
           })
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def get_guidances_groups(id)
    @plan = Plan.includes(
      :guidance_groups, template: [:phases]
    ).find(id)
    authorize @plan
    current_locale = Language.where(abbreviation: @plan.template.locale).first

    @visibility = if @plan.visibility.present?
                    @plan.visibility.to_s
                  else
                    Rails.configuration.x.plans.default_visibility
                  end

    @all_guidance_groups = if @plan.structured?.eql?(true)
                             GuidanceGroup.published.where(language_id: current_locale.id)
                           else
                             @plan.guidance_group_options.where(language_id: current_locale.id)
                           end
    @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)
    @selected_guidance_groups = @plan.guidance_groups.ids.to_set

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
            language_id: item.language_id
          }
        end
      }
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
# rubocop:enable Metrics/ClassLength
