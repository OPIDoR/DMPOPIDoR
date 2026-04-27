# frozen_string_literal: true

module OrgAdmin
  # Controller that handles guidance edition
  class GuidanceGroupsController < ApplicationController
    after_action :verify_authorized

    # GET /org_admin/guidance_groups/:id
    def show
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
      @guidance_group = GuidanceGroup.find(params[:id])
      @topics = Registry.find_by(name: 'Topics')&.values || []
      authorize @guidance_group
      @locales = Language.all
      respond_to do |format|
        format.html
        format.json { render json: GuidanceGroup.serialize_json_response(@guidance_group) }
      end
    end

    # GET /org/admin/guidance_groups/new
    def new
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
      @guidance_group = GuidanceGroup.new(org_id: current_user.org.id)
      authorize @guidance_group
      @locales = Language.all
      @topics = Registry.find_by(name: 'Topics')&.values || []
    end

    # POST /org_admin/guidance_groups/create
    # rubocop:disable Metrics/AbcSize
    def create
      # Ensure that the user can only create GuidanceGroups for their Org
      args = guidance_group_params.to_h.merge({ org_id: current_user.org.id })
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
      @guidance_group = GuidanceGroup.new(args)
      authorize @guidance_group
      @locales = Language.all

      if @guidance_group.save
        flash[:notice] = success_message(@guidance_group, _('created'))
        redirect_to edit_org_admin_guidance_group_path(@guidance_group)
      else
        flash[:alert] = failure_message(@guidance_group, _('create'))
        redirect_to new_org_admin_guidance_group_path(@guidance_group)
      end
    end
    # rubocop:enable Metrics/AbcSize

    # GET /org_admin/guidance_groups/:id/edit
    def edit
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
      @guidance_group = GuidanceGroup.find(params[:id])
      @topics = Registry.find_by(name: 'Topics')&.values || []
      authorize @guidance_group
      @locales = Language.all
      respond_to do |format|
        format.html
        format.json { render json: GuidanceGroup.serialize_json_response(@guidance_group) }
      end
    end

    # PUT /org_admin/guidance_groups/:id
    # rubocop:disable Metrics/AbcSize
    def update
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
      @guidance_group = GuidanceGroup.find(params[:id])
      authorize @guidance_group
      @locales = Language.all

      if @guidance_group.update(guidance_group_params)
        flash[:notice] = success_message(@guidance_group, _('saved'))
      else
        flash[:alert] = failure_message(@guidance_group, _('save'))
      end
      redirect_to edit_org_admin_guidance_group_path(@guidance_group)
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/guidance_groups/:id/publish
    def publish
      @guidance_group = GuidanceGroup.find(params[:id])
      authorize @guidance_group
      @locales = Language.all

      if @guidance_group.update(published: true)
        flash[:notice] = _('Your guidance group has been published and is now available to users.')

      else
        flash[:alert] = failure_message(@guidance_group, _('publish'))
      end
      redirect_to org_admin_guidances_path
    end

    # PUT /org_admin/guidance_groups/:id/unpublish
    def unpublish
      @guidance_group = GuidanceGroup.find(params[:id])
      authorize @guidance_group
      @locales = Language.all

      if @guidance_group.update(published: false)
        flash[:notice] = _('Your guidance group is no longer published and will not be available to users.')
      else
        flash[:alert] = failure_message(@guidance_group, _('unpublish'))
      end
      redirect_to org_admin_guidances_path
    end

    # DELETE /org_admin/guidance_groups/:id
    def destroy
      @guidance_group = GuidanceGroup.find(params[:id])
      @locales = Language.all
      authorize @guidance_group
      if @guidance_group.destroy
        flash[:notice] = success_message(@guidance_group, _('deleted'))
      else
        flash[:alert] = failure_message(@guidance_group, _('delete'))
      end
      redirect_to org_admin_guidances_path
    end

    private

    def guidance_group_params
      params.require(:guidance_group).permit(:org_id, :name, :description, :published, :optional_subset, :language_id,
                                             data_types: [],
                                             topics: [])
    end
  end
end
