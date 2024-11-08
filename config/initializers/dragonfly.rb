# frozen_string_literal: true

require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  # set in credentials file
  secret ENV.fetch('DRAGON_FLY_SECRET', Rails.application.credentials.dragonfly_secret)

  url_format ENV.fetch('DRAGONFLY_URL_FORMAT', '/media/:job/:name')

  # If the DRAGONFLY_AWS environment variable is set to 'true', configure the app to
  # use Amazon S3 for storage:
  if ENV.fetch('DRAGONFLY_AWS', true).to_s.casecmp('true').zero? == 'true'
    require 'dragonfly/s3_data_store'
    datastore(:s3, {
                bucket_name: ENV.fetch('AWS_BUCKET_NAME', nil),
                access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID',
                                         Rails.application.credentials.aws.access_key_id),
                secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY',
                                             Rails.application.credentials.aws.secret_access_key),
                region: ENV.fetch('AWS_REGION', nil),
                root_path: Rails.env,
                url_scheme: 'https'
              })

  # Otherwise, revert to the default:
  else

    datastore(:file, {
                root_path: Rails.root.join('public/system/dragonfly', Rails.env),
                server_root: Rails.root.join('public')
              })

  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
