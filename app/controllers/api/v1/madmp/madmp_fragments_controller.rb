# frozen_string_literal: true
require "jsonpath"

module Api

  module V1

    module Madmp

      class MadmpFragmentsController < BaseApiController

        respond_to :json
        rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

        # GET /api/v1/madmp/fragments/:id
        def show
          @fragment = MadmpFragment.find(params[:id])
          # check if the user has permissions to use the API
          unless Api::V1::Madmp::MadmpFragmentsPolicy.new(client, @fragment).show?
            render_error(errors: "Unauthorized to access plan", status: :unauthorized)
            return
          end
      
          fragment_data = query_params[:mode] == "fat" ? @fragment.get_full_fragment(with_ids: true) : @fragment.data
      
          fragment_data = select_property(fragment_data, query_params[:property])
      
          render json: {
            "data" => fragment_data,
            "dmp_id" => @fragment.dmp_id,
            "schema" => @fragment.madmp_schema.schema
          }
        end

        # GET /api/v1/madmp/dmp_fragments/:id
        def dmp_fragments
          @dmp_fragment = Fragment::Dmp.find(params[:id])
          # check if the user has permissions to use the API
          unless Api::V1::Madmp::MadmpFragmentsPolicy.new(client, @dmp_fragment).dmp_fragments?
            render_error(errors: "Unauthorized to access plan", status: :unauthorized)
            return
          end

          @dmp_fragments = MadmpFragment.where(dmp_id: @dmp_fragment.id).order(:id).map do |f|
            {
              "id" => f.id,
              "data" => f.data,
              "schema" => f.madmp_schema.schema
            }
          end
          @dmp_fragments.unshift({
            "id" => @dmp_fragment.id,
            "data" => @dmp_fragment.data,
            "schema" => @dmp_fragment.madmp_schema.schema
          })
          render json: {
            "dmp_id" => @dmp_fragment.id,
            "data" => @dmp_fragments,
            "schema" => @dmp_fragment.madmp_schema.schema
          }
        end

        # PUT/PATCH /api/v1/madmp/fragments/:id
        def update
          @fragment = MadmpFragment.find(params[:id])

          # check if the user has permissions to use the API
          unless Api::V1::Madmp::MadmpFragmentsPolicy.new(client, @fragment).update?
            render_error(errors: "Unauthorized to access plan", status: :unauthorized)
            return
          end

          @fragment.import_with_ids(params[:data], @fragment.madmp_schema)

          render json: {
            "data" => @fragment.data,
            "dmp_id" => @fragment.dmp_id,
            "schema" => @fragment.madmp_schema.schema
          }
        end

        private

        def select_property(fragment_data, property_name)
          if property_name.present?
            fragment_data = JsonPath.on(fragment_data, "$..#{property_name}")
          end
          fragment_data
        end
      
        def query_params
          params.permit(:mode, :property)
        end

        def record_not_found
          render_error(
            errors: [d_("dmpopidor", "Fragment doesn't exist.")],
            status: :not_found
          )
        end

      end
    end
  end
end