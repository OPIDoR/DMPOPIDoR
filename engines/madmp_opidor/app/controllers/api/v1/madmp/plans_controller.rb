# frozen_string_literal: true

module Api
  module V1
    module Madmp

      # Handles CRUD operations for MadmpSchemas in API V1
      class PlansController < BaseApiController
        respond_to :json
        include MadmpExportHelper
        include ErrorHelper
        # GET /api/v1/madmp/plans/:id(/research_outputs/:uuid)
        # GET /api/v1/madmp/plans/research_outputs/:uuid
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def show
          if params[:id].present?
            plan = Api::V1::PlansPolicy::Scope.new(client, Plan).resolve.find(params[:id])
            selected_research_outputs = plan.research_output_ids
          else
            plan = Plan.joins(:research_outputs)
                       .where(research_outputs: { uuid: params[:uuid] }).first
            plan.add_api_client!(client) if client.is_a?(ApiClient)
            selected_research_outputs = plan.research_outputs.where(uuid: params[:uuid]).pluck(:id)
          end

          plan_fragment = plan.json_fragment
          export_format = params[:export_format]
          respond_to do |format|
            format.json
            if export_format.eql?('rda')
              render 'shared/export/madmp_export_templates/rda/plan', locals: {
                dmp: plan_fragment, selected_research_outputs:
              }
            else
              render 'shared/export/madmp_export_templates/default/plan', locals: {
                dmp: plan_fragment, selected_research_outputs:
              }
            end
            return
          end
        rescue ActiveRecord::RecordNotFound
          render_error(errors: [_('Plan not found')], status: :not_found)
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # POST /api/v1/madmp/plans/import
        def import
          return forbidden(_('You are not allowed to create plan')) unless Api::V0::PlansPolicy.new(client, Plan).create?

          body = request.body.read
          json = JSON.parse(body)

          file = Tempfile.new(['plan', '.json'])
          file.write(json['plan'].to_json)
          file.rewind

          plan = ::Plan.new

          begin
            plan_importer = Import::Plan.new
            data = plan_importer.import(plan, {
              locale: params[:locale],
              context: params[:context],
              format: params[:import_format],
              json_file: file
            }, determine_owner(client: client, dmp: json['plan']))

            render json: { status: 201, message: _('Plan imported successfully'), data: data }, status: :created
          rescue StandardError => errs
            Rails.logger.error errs.backtrace
            bad_request(errs)
          rescue IOError
            bad_request(_('Unvalid file'))
          rescue JSON::ParserError
            bad_request(_('File should contain JSON'))
          rescue StandardError => e
            Rails.logger.error e.backtrace
            bad_request("#{_('An error has occured: ')} #{e.message}")
          end
        end

        # Get the Plan's owner
        def determine_owner(client:, dmp:)
          if client.is_a?(User)
            client
          else
            contact = dmp.dig('meta', 'contact', 0, 'person')
            user = User.find_by(email: contact['mbox'])
            return user if user.present?

            org = client.org || Org.find_by(name: 'PLEASE CHOOSE AN ORGANISATION IN YOUR PROFILE')
            User.invite!({ email: contact['mbox'],
                           firstname: contact['firstName'],
                           surname: contact['lastName'],
                           org: }, User.first) # invite! needs a User, put the SuperAdmin as the inviter
          end
        end

        private

        def select_research_output(plan_fragment, _selected_research_outputs)
          plan_fragment.data['researchOutput'] = plan_fragment.data['researchOutput'].select do |r|
            r == { 'dbid' => research_output_id }
          end
          plan_fragment
        end

        def query_params
          params.permit(:mode, research_outputs: [])
        end
      end
    end
  end
end
