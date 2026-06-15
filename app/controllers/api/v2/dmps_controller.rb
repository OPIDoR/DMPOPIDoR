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

      def show
        plan = PlansQuery.new(client, params, params[:id]).call.first

        if plan.present?
          render json: {
            dmp: Export::RdaV11::StandardToRda.new(plan).call
          }
        else
          render_error(errors: [{
                         error_message: _('Plan not found'),
                         error_code: 'dmp_not_found'
                       }], status: :not_found)
        end
      end
    end
  end
end
