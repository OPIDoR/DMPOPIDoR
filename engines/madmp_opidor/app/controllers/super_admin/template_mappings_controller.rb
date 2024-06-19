# frozen_string_literal: true

require 'jsonpath'

module SuperAdmin
  class TemplateMappingsController < ApplicationController
    include Dmpopidor::ErrorHelper
    respond_to :json, :html
    protect_from_forgery with: :null_session, only: %i[create update destroy] # use with: :exception instead of :null_session ?

    # GET /super_admin/template_mappings
    def index
      authorize(TemplateMapping)
      @mappings = TemplateMapping.all
      respond_to do |format|
        format.html # index.html.erb
        format.json do
          render json: { message: 'DMPOPIDoR mappings',
                         mappings: @mappings.as_json }
        end
      end
    end

    # GET /super_admin/template_mappings/:id
    def show
      authorize(TemplateMapping)
      mapping = TemplateMapping.find_by(id: params[:id])
      if mapping
        render json: { message: "DMPOPDIoR mapping for [#{params[:id]}]", **mapping.as_json }, status: :ok
      else
        render json: { message: 'Mapping not found' }, status: :not_found
      end
    end

    # POST /super_admin/template_mappings
    def create
      # authorize(TemplateMapping) # Not working
      mapping = TemplateMapping.new(mapping_params)
      if mapping.save
        render json: { message: 'Mapping created', **mapping.as_json }, status: :created
      else
        render json: { message: 'Error creating mapping', errors: mapping.errors.full_messages }, status: :bad_request
      end
    end

    # PATCH/PUT /super_admin/template_mappings/:id
    def update
      # authorize(TemplateMapping) # Not working
      mapping = TemplateMapping.find_by(id: params[:id])
      if mapping
        if mapping.update(mapping_params)
          render json: { message: 'Mapping updated', **mapping.as_json }, status: :ok
        else
          render json: { message: 'Error updating mapping', errors: mapping.errors.full_messages }, status: :bad_request
        end
      else
        render json: { message: 'Mapping not found' }, status: :not_found
      end
    end

    # DELETE /super_admin/template_mappings/:id
    def destroy
      # authorize(TemplateMapping) # Not working
      mapping = TemplateMapping.find_by(id: params[:id])
      if mapping
        if mapping.destroy
          render json: { message: 'Mapping deleted', **mapping.as_json }, status: :ok
        else
          render json: { message: 'Error deleting mapping', errors: mapping.errors.full_messages }, status: :bad_request
        end
      else
        render json: { message: 'Mapping not found' }, status: :not_found
      end
    end

    private

    def mapping_params
      params.permit(:type_mapping, :source_id, :target_id, :name, mapping: {})
    end
  end
end
