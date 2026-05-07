# frozen_string_literal: true

# Controller for health check endpoint
class HealthController < ApplicationController
  def show
    render json: { status: 'Healthy' }
  end
end
