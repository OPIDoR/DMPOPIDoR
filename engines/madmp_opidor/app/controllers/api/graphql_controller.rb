# frozen_string_literal: true

module Api
  class GraphqlController < V1::BaseApiController

    respond_to :json

    before_action :authorize_request
    skip_before_action :authorize_request, if: -> { params[:query].present? && params[:query].include?('authenticate') }

    def execute
      variables = prepare_variables(params[:variables])
      query = params[:query]
      operation_name = params[:operationName]
      context = {
        current_user: @client
      }
      result = DmpRoadmapSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
      render json: result
    rescue StandardError => error
      raise error unless Rails.env.development?

      handle_error_in_development(error)
    end

    private

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
