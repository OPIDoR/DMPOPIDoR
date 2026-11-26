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
    end
  end
end
