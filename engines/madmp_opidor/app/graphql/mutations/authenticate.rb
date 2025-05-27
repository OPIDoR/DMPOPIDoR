# frozen_string_literal: true

module Mutations
  # Authenticate
  class Authenticate < BaseMutation
    argument :grant_type, String, required: true
    argument :email, String, required: false
    argument :code, String, required: false

    argument :client_id, String, required: false
    argument :client_secret, String, required: false

    field :access_token, String, null: false
    field :token_type, String, null: false
    field :expires_in, Integer, null: false
    field :created_at, String, null: false

    def resolve(grant_type:, email: nil, code: nil, client_id: nil, client_secret: nil)
      json = case grant_type
             when 'authorization_code'
               { grant_type: grant_type, email: email, code: code }
             when 'client_credentials'
               { grant_type: grant_type, client_id: client_id, client_secret: client_secret }
             else
               raise GraphQL::ExecutionError, 'Invalid grant type'
             end

      auth_svc = Api::V1::Auth::Jwt::AuthenticationService.new(json:)
      @token = auth_svc.call

      {
        access_token: @token,
        token_type: 'Bearer',
        expires_in: auth_svc.expiration,
        created_at: Time.now.to_formatted_s(:iso8601)
      }
    end
  end
end
