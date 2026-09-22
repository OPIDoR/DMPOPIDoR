# frozen_string_literal: true

module OrgAdmin
  # Controller that handles guidance edition
  class GuidanceGroupsController < ApplicationController
    after_action :verify_authorized
    include ErrorHelper

    # GET /org_admin/guidance_groups
    def index
      authorize GuidanceGroup
      guidance_groups = GuidanceGroup.includes(:org, :language)
                                     .by_org(current_user.org)

      render json: {
        guidance_groups: guidance_groups.map do |gg|
          GuidanceGroup.serialize_json_response(gg)
        end
      }
    end

    # GET /org_admin/guidance_groups/:id
    def show
      guidance_group = GuidanceGroup.includes(:language).find(params[:id])
      authorize guidance_group
      render json: GuidanceGroup.serialize_json_response(guidance_group)
    end

    # GET /org/admin/guidance_groups/new
    def new
      guidance_group = GuidanceGroup.new(org_id: current_user.org.id)
      authorize guidance_group
      render json: GuidanceGroup.serialize_json_response(guidance_group)
    end

    # POST /org_admin/guidance_groups/create
    def create
      # Ensure that the user can only create GuidanceGroups for their Org
      args = guidance_group_params.to_h.merge({ org_id: current_user.org.id })
      guidance_group = GuidanceGroup.new(args)
      authorize guidance_group

      if guidance_group.save
        render json: GuidanceGroup.serialize_json_response(guidance_group)
      else
        bad_request(failure_message(guidance_group, _('create')))
      end
    end

    # GET /org_admin/guidance_groups/:id/edit
    def edit
      guidance_group = GuidanceGroup.includes(:language).find(params[:id])
      authorize guidance_group
      render json: GuidanceGroup.serialize_json_response(guidance_group)
    end

    # PUT /org_admin/guidance_groups/:id
    def update
      guidance_group = GuidanceGroup.includes(:language).find(params[:id])
      authorize guidance_group

      if guidance_group.update(guidance_group_params)
        render json: GuidanceGroup.serialize_json_response(guidance_group)
      else
        bad_request(failure_message(guidance_group, _('create')))
      end
    end

    # PUT /org_admin/guidance_groups/:id/publish
    def publish
      guidance_group = GuidanceGroup.find(params[:id])
      authorize guidance_group

      if guidance_group.update(published: true)
        render json: { status: 200,
                       message: _('Your guidance group has been published and is now available to users.') }
      else
        bad_request(failure_message(guidance_group, _('publish')))
      end
    end

    # PUT /org_admin/guidance_groups/:id/unpublish
    def unpublish
      guidance_group = GuidanceGroup.find(params[:id])
      authorize guidance_group

      if guidance_group.update(published: false)
        render json: { status: 200,
                       message: _('Your guidance group is no longer published and will not be available to users.') }
      else
        bad_request(failure_message(guidance_group, _('publish')))
      end
    end

    # DELETE /org_admin/guidance_groups/:id
    def destroy
      guidance_group = GuidanceGroup.find(params[:id])
      authorize guidance_group
      if guidance_group.destroy
        guidance_groups = GuidanceGroup.includes(:org, :language)
                                       .by_org(current_user.org).page(1)

        render json: {
          message: success_message(guidance_group, _('deleted')),
          guidance_groups: guidance_groups.map do |gg|
            GuidanceGroup.serialize_json_response(gg)
          end
        }
      else
        bad_request(failure_message(guidance_group, _('delete')))
      end
    end

    private

    def guidance_group_params
      params.require(:guidance_group).permit(:org_id, :name, :description, :published, :language_id, :is_default,
                                             data_types: [],
                                             topics: [])
    end
  end
end
