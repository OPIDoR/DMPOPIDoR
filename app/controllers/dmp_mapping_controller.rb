# frozen_string_literal: true

require 'jsonpath'

class DmpMappingController < ApplicationController
  include Dmpopidor::ErrorHelper
  respond_to :json
  skip_before_action :verify_authenticity_token, only: [:create] # TODO: Not a good practice, CSRF issues may arise

  # GET /dmp_mappings
  def index
    mappings = DmpMapping.all
    render json: { status: 200, message: 'DMPOPDIoR mappings', data: mappings }
  end

  # GET /dmp_mappings/:id
  def show
    mapping = DmpMapping.find_by(id: params[:id])
    if mapping
      render json: { status: 200, message: "DMPOPDIoR mapping for [#{params[:id]}]", data: mapping }
    else
      render json: { status: 404, message: 'Mapping not found' }
    end
  end

  # POST /dmp_mappings
  def create
    mapping = DmpMapping.new(mapping_params)
    if mapping.save
      render json: { status: 201, message: 'Mapping created', data: mapping }
    else
      render json: { status: 400, message: 'Error creating mapping', errors: mapping.errors.full_messages }
    end
  end

  # PATCH/PUT /dmp_mappings/:id
  def update
    mapping = DmpMapping.find_by(id: params[:id])
    if mapping&.update(mapping_params)
      render json: { status: 200, message: 'Mapping updated', data: mapping }
    else
      render json: { status: 400, message: 'Error updating mapping', errors: mapping.errors.full_messages }
    end
  end

  # DELETE /dmp_mappings/:id
  def delete
    mapping = DmpMapping.find_by(id: params[:id])
    if mapping&.destroy
      render json: { status: 200, message: 'Mapping deleted' }
    else
      render json: { status: 400, message: 'Error deleting mapping' }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def mapping_params
    params.require(:dmp_mapping).permit(:type_mapping, :source_id, :target_id, mapping: {})
  end
end
