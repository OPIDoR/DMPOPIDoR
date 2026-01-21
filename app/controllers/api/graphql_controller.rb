# frozen_string_literal: true

module Api
  # GraphqlController
  class GraphqlController < V1::BaseApiController
    respond_to :json

    before_action -> { @query = params[:query]; authorize_request unless public_query?(@query) }

    # rubocop:disable Metrics/AbcSize
    def execute
      context = public_query?(@query) ? {} : { current_user: @client }
      variables = prepare_variables(params[:variables])
      result = DmpRoadmapSchema.execute(@query, variables: variables, context: context, operation_name: params[:operationName])
      render json: result
    rescue StandardError => e
      handle_error_in_development(e)
    end
    # rubocop:enable Metrics/AbcSize

    private

    def public_query?(query)
      query.present? && (query.include?('__schema') || query.include?('authenticate') || query.include?('publicPlans'))
    end

    def prepare_variables(variables_param)
      case variables_param
      when String
        if variables_param.present?
          JSON.parse(variables_param) || {}
        else
          {}
        end
      when Hash
        variables_param
      when ActionController::Parameters
        variables_param.to_unsafe_hash
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{variables_param}"
      end
    end

    def handle_error_in_development(error)
      logger.error error.message
      logger.error error.backtrace.join("\n")

      render json: { errors: [{ message: error.message, backtrace: error.backtrace }], data: {} }, status: 500
    end
  end
end
