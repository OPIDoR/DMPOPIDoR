# frozen_string_literal: true

class HealthController < ApplicationController
  def show
    puts ActiveRecord::Base.connection_db_config.database
    render json: { status: "Healthy" }
  end
end
