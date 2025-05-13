# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the guidance groups table
  class GuidanceGroupsController < ApplicationController
    include Paginable
    prepend Dmpopidor::Paginable::GuidanceGroupsController

    # /paginable/guidance_groups/index/:page
    def index
      authorize(Guidance)
      paginable_renderise(
        partial: 'index',
        scope: GuidanceGroup.includes(:org).by_org(current_user.org),
        query_params: { sort_field: 'guidance_groups.name', sort_direction: :asc },
        format: :json
      )
    end

    # GET /paginable/guidance_groups/publicly_visible/:page  (AJAX)
    # -----------------------------------------------------
    def publicly_visible
      # We want the pagination/sort/search to be retained in the URL so redirect instead
      # of processing this as a JSON
      paginable_params = params.permit(:page, :search, :sort_field, :sort_direction)
      redirect_to public_guidance_groups_path(paginable_params.to_h)
    end
  end
end
