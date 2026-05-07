# frozen_string_literal: true

module OrgAdmin
  # Controller that handles guidance edition
  class GuidancesController < ApplicationController
    after_action :verify_authorized

    # GET /org_admin/guidances
    def index
      authorize Guidance
      @guidances = Guidance.includes(:guidance_group, :themes)
                           .by_org(current_user.org).page(1)
      ensure_default_group(current_user.org)
      @guidance_groups = GuidanceGroup.includes(:org)
                                      .by_org(current_user.org).page(1)

      respond_to do |format|
        format.html
        format.json do
          render json: {
            guidance_groups: @guidance_groups.map do |gg|
              GuidanceGroup.serialize_json_response(gg)
            end,
            guidances: @guidances.map do |g|
              Guidance.serialize_json_response(g)
            end
          }
        end
      end
    end

    # GET /org_admin/guidances/new
    def new
      @guidance = Guidance.new
      authorize @guidance
      @locales = Language.all
      render :new_edit
    end

    # GET /org_admin/guidances/:id/edit
    def edit
      @guidance = Guidance.eager_load(:themes, :guidance_group)
                          .find(params[:id])
      authorize @guidance

      @locales = Language.all

      render :new_edit
    end

    # POST /org_admin/guidances
    # rubocop:disable Metrics/AbcSize
    def create
      @guidance = Guidance.new(guidance_params)
      authorize @guidance

      @locales = Language.all

      if @guidance.save
        if @guidance.published?
          guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
          if !guidance_group.published? || guidance_group.published.nil?
            guidance_group.published = true
            guidance_group.save
          end
        end
        flash[:notice] = success_message(@guidance, _('created'))
        redirect_to edit_org_admin_guidance_path(@guidance)
      else
        flash[:alert] = failure_message(@guidance, _('create'))
        redirect_to new_org_admin_guidance_path(@guidance)
      end
    end
    # rubocop:enable Metrics/AbcSize
    #
    #

    # PUT /org_admin/guidances/:id
    # rubocop:disable Metrics/AbcSize
    def update
      @guidance = Guidance.find(params[:id])
      authorize @guidance

      @locales = Language.all

      if @guidance.update(guidance_params)
        if @guidance.published?
          guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
          if !guidance_group.published? || guidance_group.published.nil?
            guidance_group.published = true
            guidance_group.save
          end
        end
        flash[:notice] = success_message(@guidance, _('saved'))
      else
        flash[:alert] = failure_message(@guidance, _('save'))
      end
      redirect_to edit_org_admin_guidance_path(@guidance)
    end
    # rubocop:enable Metrics/AbcSize

    # DELETE /org_admin/guidances/:id
    # rubocop:disable Metrics/AbcSize
    def destroy
      @guidance = Guidance.find(params[:id])
      authorize @guidance
      guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
      if @guidance.destroy
        unless guidance_group.guidances.where(published: true).exists?
          guidance_group.published = false
          guidance_group.save
        end
        flash[:notice] = success_message(@guidance, _('deleted'))
      else
        flash[:alert] = failure_message(@guidance, _('delete'))
      end
      redirect_to(action: :index)
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/guidances/:id/publish
    # rubocop:disable Metrics/AbcSize
    def publish
      @guidance = Guidance.find(params[:id])
      authorize @guidance
      if @guidance.update(published: true)
        guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
        guidance_group.update(published: true) if !guidance_group.published? || guidance_group.published.nil?
        flash[:notice] = _('Your guidance has been published and is now available to users.')

      else
        flash[:alert] = failure_message(@guidance, _('publish'))
      end
      redirect_to(action: :index)
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/guidances/:id/unpublish
    # rubocop:disable Metrics/AbcSize
    def unpublish
      @guidance = Guidance.find(params[:id])
      authorize @guidance
      if @guidance.update(published: false)
        guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
        guidance_group.update(published: false) unless guidance_group.guidances.where(published: true).exists?
        flash[:notice] = _('Your guidance is no longer published and will not be available to users.')

      else
        flash[:alert] = failure_message(@guidance, _('unpublish'))
      end
      redirect_to(action: :index)
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def render_themes
      authorize Guidance
      guidance_group = GuidanceGroup.find(params[:guidance_group_id])

      guidance = if params[:guidance_id].present?
                   Guidance.eager_load(:themes, :guidance_group).find(params[:guidance_id])
                 end

      selected_theme = (guidance.themes[0].title if guidance&.themes&.any?)

      rendered_partial = GuidancesController.new.render_to_string(
        {
          partial: 'org_admin/shared/theme_selector',
          locals: {
            f: form_builder_for(guidance || Guidance.new),
            all_themes: Theme.where(data_type: guidance_group&.data_types).order('title'),
            as_radio: true,
            required: true,
            in_error: false,
            selected_theme: selected_theme,
            locale_id: guidance_group.language&.id,
            popover_message: _('Select one or more themes that are relevant to this guidance. This will display your generic organisation-level guidance, or any Schools/Departments for which you create guidance groups, across all templates that have questions with the corresponding theme tags.') # rubocop:disable Layout/LineLength
          }
        }
      )

      render json: { status: 200, error: 'Themes results', data: {
        partial: rendered_partial,
        locale: guidance_group.language.name
      } }, status: :ok
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def form_builder_for(object)
      ActionView::Helpers::FormBuilder.new(:guidance, object, self, {})
    end

    private

    def guidance_params
      params.require(:guidance).permit(:guidance_group_id, :text, :published, theme_ids: [])
    end

    def ensure_default_group(org)
      return unless org.managed?
      return if org.guidance_groups.length.positive?

      GuidanceGroup.create_org_default(org)
    end
  end
end
