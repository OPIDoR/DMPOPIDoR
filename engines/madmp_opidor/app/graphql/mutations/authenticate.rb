module Mutations
  class Authenticate < BaseMutation
    argument :grant_type, String, required: true
    argument :email, String, required: true
    argument :code, String, required: true

    field :access_token, String, null: false
    field :token_type, String, null: false
    field :expires_in, Integer, null: false
    field :created_at, String, null: false

    def resolve(grant_type:, email:, code:)
      raise GraphQL::ExecutionError, "Invalid grant type" if grant_type != "authorization_code"

      auth_svc = Api::V1::Auth::Jwt::AuthenticationService.new(json: {
        grant_type: grant_type,
        email: email,
        code: code,
      })
      @token = auth_svc.call

      {
        "access_token": @token,
        "token_type": "Bearer",
        "expires_in":  auth_svc.expiration,
        "created_at": Time.now.to_formatted_s(:iso8601)
      }
    end
  end
end
