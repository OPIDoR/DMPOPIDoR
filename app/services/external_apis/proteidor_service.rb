# frozen_string_literal: true

require 'openssl'

# TEMPORARY: Disable SSL verification for Proteidor API requests
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module ExternalApis
  # This service provides an interface to ORCiD API
  class ProteidorService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def api_base_url
        Rails.configuration.x.proteidor&.api_base_url || super
      end

      def active?
        Rails.configuration.x.proteidor&.active || super
      end

      def formats_path
        Rails.configuration.x.proteidor&.formats_path
      end

      def export_path
        Rails.configuration.x.proteidor&.export_path
      end

      # Ping the Proteidor API to determine if it is online
      #
      # @return true/false
      def ping?
        return true unless active?

        resp = http_get(uri: api_base_url)
        resp&.code == 200
      end

      def formats
        return [] unless active? && formats_path.present?

        resp = http_get(uri: "#{api_base_url}#{formats_path}")
        JSON.parse(resp.body)
      end

      def export(json_plan, template_id, format)
        return nil unless active? && template_id.present? && format.present?

        resp = http_post(
          uri: "#{api_base_url}#{export_path}/#{template_id}/#{format}",
          additional_headers: {},
          data: { dmpData: json_plan }.to_json
        )

        unless resp.present? && [200, 201].include?(resp.code)
          handle_http_failure(method: 'ProteidorService export', http_response: resp)
          return nil
        end
        resp.body
      end
    end
  end
end
