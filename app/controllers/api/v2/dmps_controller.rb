# frozen_string_literal: true

module Api
  module V2
    # Endpoints for new RDA DMP common API
    class DmpsController < Api::V1::BaseApiController
      respond_to :json
      def index
        plans = PlansQuery.new(client, params).call
        render json: {
          total_count: plans.size,
          items: plans.map do |plan|
            {
              dmp: Export::RdaV11::StandardToRda.new(plan).call
            }
          end
        }
      end
    end
  end
end
