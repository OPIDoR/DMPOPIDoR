# frozen_string_literal: true

require 'json'

# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
# rubocop:disable Metrics/BlockLength
Devise.setup do |config|
  config.secret_key = ENV.fetch('DEVISE_SECRET_KEY', Rails.application.credentials.secret_key)

  # ==> Mailer Configuration
  # Configure the e-mail address which will be shown in Devise::Mailer,
  # note that it will be overwritten if you use your own mailer class with
  # default "from" parameter.
  config.mailer_sender = ENV.fetch('MAILER_FROM', 'no-reply@email.address')

  # Configure the class responsible to send e-mails.
  # config.mailer = "Devise::Mailer"

  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default) and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'devise/orm/active_record'

  # ==> Configuration for any authentication mechanism
  # Configure which keys are used when authenticating a user. The default is
  # just :email. You can configure it to use [:username, :subdomain], so for
  # authenticating a user, both parameters are required. Remember that those
  # parameters are used only when authenticating and not when retrieving from
  # session. If you need permissions, you should implement that in a before filter.
  # You can also supply a hash where the value is a boolean determining whether
  # or not authentication should be aborted when the value is not present.
  # config.authentication_keys = [ :email ]

  # Configure parameters from the request object used for authentication. Each entry
  # given should be a request method and it will automatically be passed to the
  # find_for_authentication method and considered in your model lookup. For instance,
  # if you set :request_keys to [:subdomain], :subdomain will be used on authentication.
  # The same considerations mentioned for authentication_keys also apply to request_keys.
  # config.request_keys = []

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [ENV.fetch('DEVISE_CASE_INSENSITIVE_KEYS', :email)&.to_sym]

  # Configure which authentication keys should have whitespace stripped.
  # These keys will have whitespace before and after removed upon creating or
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [ENV.fetch('DEVISE_STRIP_WITHESPACE_KEYS', :email)&.to_sym]

  # Tell if authentication through request.params is enabled. True by default.
  # It can be set to an array that will enable params authentication only for the
  # given strategies, for example, `config.params_authenticatable = [:database]` will
  # enable it only for database (email + password) authentication.
  # config.params_authenticatable = true

  # Tell if authentication through HTTP Auth is enabled. False by default.
  # It can be set to an array that will enable http authentication only for the
  # given strategies, for example, `config.http_authenticatable = [:token]` will
  # enable it only for token authentication. The supported strategies are:
  # :database      = Support basic authentication with authentication key + password
  # :token         = Support basic authentication with token authentication key
  # :token_options = Support token authentication with options as defined in
  #       http://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token.html
  # config.http_authenticatable = false

  # If http headers should be returned for AJAX requests. True by default.
  config.http_authenticatable_on_xhr = ENV.fetch('HTTP_AUTHENTICATABLE_ON_XHR', false).to_s.casecmp('true').zero?

  # The realm used in Http Basic Authentication. "Application" by default.
  # config.http_authentication_realm = "Application"

  # It will change confirmation, password recovery and other workflows
  # to behave the same regardless if the e-mail provided was right or wrong.
  # Does not affect registerable.
  # config.paranoid = true

  # By default Devise will store the user in session. You can skip storage for
  # :http_auth and :token_auth by adding those symbols to the array below.
  # Notice that if you are skipping storage for all authentication paths, you
  # may want to disable generating routes to Devise's sessions controller by
  # passing :skip => :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [ENV.fetch('DEVISE_SKIP_SESSION_STORAGE', :http_auth)&.to_sym]

  # ==> Configuration for :database_authenticatable
  # For bcrypt, this is the cost for hashing the password and defaults to 10. If
  # using other encryptors, it sets how many times you want the password re-encrypted.
  #
  # Limiting the stretches to just one in testing will increase the performance of
  # your test suite dramatically. However, it is STRONGLY RECOMMENDED to not use
  # a value less than 10 in other environments.
  config.stretches = Rails.env.test? ? 1 : 10

  # Setup a pepper to generate the encrypted password.
  # the pepper is now set in credentials.yml.enc which can be edited by setting up
  # the key in your environment with
  # export RAILS_MASTER_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  # and then editing the credentials file with
  # EDITOR=your_fave_editor rails credentials:edit
  config.pepper = ENV.fetch('DEVISE_PEPPER', Rails.application.credentials.devise_pepper)

  # ==> Configuration for :invitable
  # The period the generated invitation token is valid, after
  # this period, the invited resource won't be able to accept the invitation.
  # When invite_for is 0 (the default), the invitation won't expire.
  # config.invite_for = 2.weeks

  # Number of invitations users can send.
  # - If invitation_limit is nil, there is no limit for invitations, users can
  # send unlimited invitations, invitation_limit column is not used.
  # - If invitation_limit is 0, users can't send invitations by default.
  # - If invitation_limit n > 0, users can send n invitations.
  # You can change invitation_limit column for some users so they can send more
  # or less invitations, even with global invitation_limit = 0
  # Default: nil
  # config.invitation_limit = 5

  # The key to be used to check existing users when sending an invitation
  # and the regexp used to test it when validate_on_invite is not set.
  # config.invite_key = {:email => /\A[^@]+@[^@]+\z/}
  # config.invite_key = {:email => /\A[^@]+@[^@]+\z/, :username => nil}

  # Flag that force a record to be valid before being actually invited
  # Default: false
  # config.validate_on_invite = true

  # ==> Configuration for :confirmable
  # A period that the user is allowed to access the website even without
  # confirming his account. For instance, if set to 2.days, the user will be
  # able to access the website for two days without confirming his account,
  # access will be blocked just in the third day. Default is 0.days, meaning
  # the user cannot access the website without confirming his account.
  # config.allow_unconfirmed_access_for = 2.days

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid. For example, if set to 3.days, the user can confirm
  # their account within 3 days after the mail was sent, but on the fourth day
  # their account can't be confirmed with the token any more.
  # Default is nil, meaning there is no restriction on how long a user can take
  # before confirming their account.
  # config.confirm_within = 3.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed new email is stored in
  # unconfirmed email column, and copied to email column on successful confirmation.
  config.reconfirmable = ENV.fetch('RENCONFIRMABLE', false) == 'false'

  # Defines which key will be used when confirming an account
  # config.confirmation_keys = [ :email ]

  # ==> Configuration for :rememberable
  # The time the user will be remembered without asking for credentials again.
  # config.remember_for = 2.weeks

  # If true, extends the user's remember period when remembered via cookie.
  # config.extend_remember_period = false

  # Options to be passed to the created cookie. For instance, you can set
  # :secure => true in order to force SSL only cookies.
  # config.rememberable_options = {}

  # ==> Configuration for :validatable
  # Range for password length. Default is 8..128.
  config.password_length = (ENV['PASSWORD_LENGTH'] || '8..128').split('..').map(&:to_i).then { |min, max| min..max }

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  # config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 3 hours.
  config.timeout_in = ENV.fetch('TIMEOUT_IN', 3.hours).to_i

  # If true, expires auth token on session timeout.
  # config.expire_auth_token_on_timeout = false

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [ :email ]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [ :email ]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = ENV.fetch('RESET_PASSWORD_WITHIN', 6.hours).to_i

  # ==> Configuration for :encryptable
  # Allow you to use another encryption algorithm besides bcrypt (default). You can use
  # :sha1, :sha512 or encryptors from others authentication tools as :clearance_sha1,
  # :authlogic_sha512 (then you should set stretches above to 20 for default behavior)
  # and :restful_authentication_sha1 (then you should set stretches to 10, and copy
  # REST_AUTH_SITE_KEY to pepper).
  #
  # Require the `devise-encryptable` gem when using anything other than bcrypt
  # config.encryptor = :sha512

  # ==> Configuration for :token_authenticatable
  # Defines name of the authentication token params key
  # config.token_authentication_key = :auth_token

  # ==> Scopes configuration
  # Turn scoped views on. Before rendering "sessions/new", it will first check for
  # "users/sessions/new". It's turned off by default because it's slower if you
  # are using only default views.
  # config.scoped_views = false

  # Configure the default scope given to Warden. By default it's the first
  # devise role declared in your routes (usually :user).
  # config.default_scope = :user

  # Set this configuration to false if you want /users/sign_out to sign out
  # only the current scope. By default, Devise signs out all scopes.
  # config.sign_out_all_scopes = true

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html, should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below is required to match Internet Explorer requests.
  config.navigational_formats = ['*/*', :html, :js]

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = ENV.fetch('DEVISE_SIGN_OUT_VIA', :delete)&.to_sym

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', :scope => 'user,public_repo'

  # Any entries here MUST match a corresponding entry in the identifier_schemes table as
  # well as an identifier_schemes.schemes section in each locale file!
  OmniAuth.config.full_host = ENV.fetch('OMNI_AUTH_FULL_HOST', 'https://my_service.hostname')
  OmniAuth.config.allowed_request_methods = [ENV.fetch('DEVISE_ALLOWED_REQUEST_METHODS', :post)&.to_sym]

  config.omniauth :orcid, ENV.fetch('DEVISE_ORCID_CLIENT_ID', 'client_id'),
                  ENV.fetch('DEVISE_ORCID_CLIENT_SECRET', 'client_secret'), { sandbox: true, scope: '/authenticate' }

  shibboleth_request_type = ENV.fetch('DEVISE_SHIBBOLETH_REQUEST_TYPE', :header).to_sym
  shibboleth_config = if ENV['DEVISE_SHIBBOLETH_CONFIG']&.present?
                        JSON.parse(ENV['DEVISE_SHIBBOLETH_CONFIG'],
                                   { symbolize_names: true })
                      else
                        {
                          uid_field: "eppn",
                          info_fields: {
                            uid: "uid",
                            eppn: "eppn",
                            email: "mail",
                            name: "displayName",
                            last_name: "sn",
                            first_name: "givenName",
                            identity_provider: "shib_identity_provider"
                          },
                          debug: ENV.fetch('DEVISE_DEBUG', false).to_s.casecmp('true').zero?
                        }
                      end
  shibboleth_extra_fields = JSON.parse(ENV.fetch('DEVISE_SHIBBOLETH_EXTRA_FIELDS',
                                                 [:schacHomeOrganization].to_json)).map(&:to_sym)
  config.omniauth :shibboleth, {
    request_type: shibboleth_request_type,
    **shibboleth_config,
    extra_fields: shibboleth_extra_fields
  }

  # ==> Warden configuration
  # If you want to use other strategies, that are not supported by Devise, or
  # change the failure app, you can configure them inside the config.warden block.
  #
  # config.warden do |manager|
  #   manager.intercept_401 = false
  #   manager.default_strategies(:scope => :user).unshift :some_external_strategy
  # end

  # ==> Mountable engine configurations
  # When using Devise inside an engine, let's call it `MyEngine`, and this engine
  # is mountable, there are some extra configurations to be taken into account.
  # The following options are available, assuming the engine is mounted as:
  #
  #     mount MyEngine, at: "/my_engine"
  #
  # The router that invoked `devise_for`, in the example above, would be:
  # config.router_name = :my_engine
  #
  # When using omniauth, Devise cannot automatically set Omniauth path,
  # so you need to do it manually. For the users scope, it would be:
  config.omniauth_path_prefix = ENV.fetch('DEVISE_OMNIAUTH_PATH_PREFIX', '/users/auth')

  config.warden do |manager|
    manager.failure_app = CustomFailure
  end
end
# rubocop:enable Metrics/BlockLength

require 'omniauth/strategies/shibboleth'
module OmniAuth
  module Strategies
    # Fix for encogind bug on some chars coming from shibboleth
    class Shibboleth
      # set encoding UTF-8 when reading from HTTP header
      # reason: header values are always ISO-8859-1,
      # so ruby reads them as ASCII-8BIT
      def request_param(key)
        multi_value_handler(
          case options.request_type
          when :env, 'env'
            request.env[key]
          when :header, 'header'
            v = request.env["HTTP_#{key.upcase.tr('-', '_')}"]
            v = v.force_encoding('UTF-8') unless v.nil?
            v
          when :params, 'params'
            request.params[key]
          end
        )
      end
    end
  end
end
