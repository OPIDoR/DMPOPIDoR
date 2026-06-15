# frozen_string_literal: true

module Api
  module V2
    # Endpoints for new RDA DMP common API
    class DmpsController < Api::V1::BaseApiController
      respond_to :json
      include ErrorHelper

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

      def create
        body = request.body.read
        json = JSON.parse(body)

        file = Tempfile.new(['plan', '.json'])
        file.write(json.to_json)
        file.rewind

        plan = Plan.new

        begin
          plan_importer = Import::Plan.new
          data = plan_importer.import(plan, {
                                        locale: determine_locale(dmp: json),
                                        context: 'research_project',
                                        format: 'rda',
                                        json_file: file
                                      }, determine_owner(client: client, dmp: json))

          render json: { status: 201, message: _('Plan imported successfully'), data: data }, status: :created
        rescue IOError
          bad_request(_('Unvalid file'))
        rescue JSON::ParserError
          bad_request(_('File should contain JSON'))
        rescue StandardError => e
          Rails.logger.error e.backtrace
          bad_request("#{_('An error has occured: ')} #{e.message}")
        end
      end

      private

      # Get the Plan's owner
      def determine_owner(client:, dmp:)
        if client.is_a?(User)
          client
        else
          contact = dmp.dig('dmp', 'contact')
          user = User.find_by(email: contact['mbox'])
          return user if user.present?

          org = client.org || Org.find_by(name: 'PLEASE CHOOSE AN ORGANISATION IN YOUR PROFILE')
          User.invite!({ email: contact['mbox'],
                         surname: contact['name'],
                         org: }, User.first) # invite! needs a User, put the SuperAdmin as the inviter
        end
      end

      def determine_locale(dmp:)
        dmp.dig('dmp', 'language').eql?('eng') ? 'en-GB' : 'fr-FR'
      end
    end
  end
end
