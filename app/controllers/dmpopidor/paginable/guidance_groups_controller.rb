# frozen_string_literal: true

module Dmpopidor
  module Paginable
    # Customized code for Paginable GuidanceGroupsController
    module GuidanceGroupsController
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
end
