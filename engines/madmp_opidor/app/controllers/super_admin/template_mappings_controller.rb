# frozen_string_literal: true

require 'jsonpath'

module SuperAdmin
  class TemplateMappingsController < ApplicationController
    include Dmpopidor::ErrorHelper
    respond_to :json, :html
    skip_before_action :verify_authenticity_token, only: %i[create update destroy] # TODO: Not a good practice, CSRF issues may arise

    # GET /dmp_mapping
    def index
      @mappings = DmpMapping.all
      respond_to do |format|
        format.html # index.html.erb
        format.json do
          render json: { message: 'DMPOPIDoR mappings',
                         mappings: @mappings.as_json(only: %i[id type_mapping source_id target_id mapping name]) }
        end
      end
    end

    # GET /dmp_mapping/:id
    def show
      mapping = DmpMapping.find_by(id: params[:id])
      if mapping
        render json: { message: "DMPOPDIoR mapping for [#{params[:id]}]", **mapping.as_json }, status: :ok
      else
        render json: { message: 'Mapping not found' }, status: :not_found
      end
    end

    # POST /dmp_mapping
    def create
      mapping = DmpMapping.new(mapping_params)
      if mapping.save
        render json: { message: 'Mapping created', **mapping.as_json }, status: :created
      else
        render json: { message: 'Error creating mapping', errors: mapping.errors.full_messages }, status: :bad_request
      end
    end

    # PATCH/PUT /dmp_mapping/:id
    def update
      mapping = DmpMapping.find_by(id: params[:id])
      if mapping&.update(mapping_params)
        render json: { message: 'Mapping updated', **mapping.as_json }, status: :ok
      else
        render json: { message: 'Error updating mapping', errors: mapping.errors.full_messages }, status: :bad_request
      end
    end

    # DELETE /dmp_mapping/:id
    def destroy
      mapping = DmpMapping.find_by(id: params[:id])
      if mapping&.destroy
        render json: { message: 'Mapping deleted' }, status: :ok
      else
        render json: { message: 'Error deleting mapping' }, status: :bad_request
      end
    end

    private

    def mapping_params
      params.require(:dmp_mapping).permit(:type_mapping, :source_id, :target_id, :name, mapping: {})
    end

    # # GET /dmp_mapping/:id
    # def show
    #   @mapping = DmpMapping.find_by(id: params[:id])
    #   respond_to do |format|
    #     format.json do
    #       if @mapping
    #         render json: { message: "DMPOPDIoR mapping for [#{params[:id]}]", **@mapping.as_json }, status: :ok
    #       else
    #         render json: { message: 'Mapping not found' }, status: :not_found
    #       end
    #     end
    #   end
    # end

    # # POST /dmp_mapping
    # def create
    #   @mapping = DmpMapping.new(mapping_params)
    #   if @mapping.save
    #     respond_to do |format|
    #       format.json { render json: { message: 'Mapping created', **@mapping.as_json }, status: :created }
    #     end
    #   else
    #     respond_to do |format|
    #       format.json do
    #         render json: { message: 'Error creating mapping', errors: @mapping.errors.full_messages },
    #                status: :bad_request
    #       end
    #     end
    #   end
    # end

    # # PATCH/PUT /dmp_mapping/:id
    # def update
    #   @mapping = DmpMapping.find_by(id: params[:id])
    #   if @mapping&.update(mapping_params)
    #     respond_to do |format|
    #       format.html { redirect_to some_path, notice: 'Mapping updated' }
    #       format.json { render json: { message: 'Mapping updated', **@mapping.as_json }, status: :ok }
    #     end
    #   else
    #     respond_to do |format|
    #       format.html { render :edit }
    #       format.json do
    #         render json: { message: 'Error updating mapping', errors: @mapping.errors.full_messages },
    #                status: :bad_request
    #       end
    #     end
    #   end
    # end

    # # DELETE /dmp_mapping/:id
    # def destroy
    #   @mapping = DmpMapping.find_by(id: params[:id])
    #   if @mapping&.destroy
    #     respond_to do |format|
    #       format.html { redirect_to some_path, notice: 'Mapping deleted' }
    #       format.json { render json: { message: 'Mapping deleted' }, status: :ok }
    #     end
    #   else
    #     respond_to do |format|
    #       format.html { redirect_to some_path, alert: 'Error deleting mapping' }
    #       format.json { render json: { message: 'Error deleting mapping' }, status: :bad_request }
    #     end
    #   end
    # end

    # private

    # def mapping_params
    #   params.require(:dmp_mapping).permit(:type_mapping, :source_id, :target_id, :name, mapping: {})
    # end
  end
end
