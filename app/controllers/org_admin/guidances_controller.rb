# frozen_string_literal: true

module OrgAdmin
  # Controller that handles guidance edition
  class GuidancesController < ApplicationController
    after_action :verify_authorized
    include ErrorHelper

    # GET /org_admin/guidances
    def index
      authorize Guidance
      guidances = Guidance.includes(:guidance_group, :themes)
                          .by_org(current_user.org)
      ensure_default_group(current_user.org)

      render json: {
        guidances: guidances.map do |g|
          Guidance.serialize_json_response(g)
        end
      }
    end

    # GET /org_admin/guidances/:id
    def show
      guidance = Guidance.eager_load(:themes, :guidance_group)
                         .find(params[:id])
      authorize guidance
      render json: Guidance.serialize_json_response(guidance)
    end

    # GET /org_admin/guidances/new
    def new
      guidance = Guidance.new
      authorize guidance
      render json: Guidance.serialize_json_response(guidance)
    end

    # GET /org_admin/guidances/:id/edit
    def edit
      guidance = Guidance.eager_load(:themes, :guidance_group)
                         .find(params[:id])
      authorize guidance
      render json: Guidance.serialize_json_response(guidance)
    end

    # POST /org_admin/guidances
    # rubocop:disable Metrics/AbcSize
    def create
      guidance = Guidance.new(guidance_params)
      authorize guidance

      if guidance.save
        if guidance.published?
          guidance_group = GuidanceGroup.find(guidance.guidance_group_id)
          if !guidance_group.published? || guidance_group.published.nil?
            guidance_group.published = true
            guidance_group.save
          end
        end
        render json: Guidance.serialize_json_response(guidance)
      else
        bad_request(failure_message(guidance, _('create')))
      end
    end
    # rubocop:enable Metrics/AbcSize
    #
    #

    # PUT /org_admin/guidances/:id
    # rubocop:disable Metrics/AbcSize
    def update
      guidance = Guidance.find(params[:id])
      authorize guidance

      if guidance.update(guidance_params)
        if guidance.published?
          guidance_group = GuidanceGroup.find(guidance.guidance_group_id)
          if !guidance_group.published? || guidance_group.published.nil?
            guidance_group.published = true
            guidance_group.save
          end
        end
        render json: Guidance.serialize_json_response(guidance)
      else
        bad_request(failure_message(guidance, _('save')))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # DELETE /org_admin/guidances/:id
    # rubocop:disable Metrics/AbcSize
    def destroy
      guidance = Guidance.find(params[:id])
      authorize guidance
      guidance_group = GuidanceGroup.find(guidance.guidance_group_id)
      if guidance.destroy
        unless guidance_group.guidances.where(published: true).exists?
          guidance_group.published = false
          guidance_group.save
        end
        guidances = guidance_group.guidances

        render json: {
          message: success_message(guidance, _('deleted')),
          guidances: guidances.map do |guidance|
            Guidance.serialize_json_response(guidance)
          end
        }
      else
        bad_request(failure_message(guidance, _('delete')))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/guidances/:id/publish
    # rubocop:disable Metrics/AbcSize
    def publish
      guidance = Guidance.find(params[:id])
      authorize guidance
      if guidance.update(published: true)
        guidance_group = GuidanceGroup.find(guidance.guidance_group_id)
        guidance_group.update(published: true) if !guidance_group.published? || guidance_group.published.nil?
        render json: { status: 200,
                       message: _('Your guidance has been published and is now available to users.') }

      else
        bad_request(failure_message(guidance, _('publish')))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # PUT /org_admin/guidances/:id/unpublish
    def unpublish
      guidance = Guidance.find(params[:id])
      authorize guidance
      if guidance.update(published: false)
        guidance_group = GuidanceGroup.find(guidance.guidance_group_id)
        guidance_group.update(published: false) unless guidance_group.guidances.where(published: true).exists?
        render json: { status: 200,
                       message: _('Your guidance is no longer published and will not be available to users.') }

      else
        bad_request(failure_message(guidance, _('unpublish')))
      end
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
