# frozen_string_literal: true

module Api
  module V2
    # Endpoints for new RDA DMP common API
    class DmpsController < Api::V1::BaseApiController
      def index
        plans = PlansQuery.new(params).call
        render json: plans # , each_serializer: Api::V2::PlanSerializer, meta: pagination_dict(plans)
      end
    end
  end
end
