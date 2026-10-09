# frozen_string_literal: true

# Controller that handles user login and logout
class SessionsController < Devise::SessionsController
  def new
    redirect_to(root_path)
  end

  # Capture the user's shibboleth id if they're coming in from an IDP
  # ---------------------------------------------------------------------
  # rubocop:disable-next Metrics/AbcSize
  def create
    existing_user = User.find_by(email: params[:user][:email])
    unless existing_user.nil?

      # Until ORCID login is supported
      unless session['devise.shibboleth_data'].nil?
        args = {
          identifier_scheme: IdentifierScheme.find_by(name: 'shibboleth'),
          value: session['devise.shibboleth_data']['uid'],
          identifiable: existing_user,
          attrs: session['devise.shibboleth_data']
        }
        @ui = Identifier.new(args)
      end
      session[:locale] = existing_user.locale unless existing_user.locale.nil?
      # Method defined at controllers/application_controller.rb
      set_locale
    end

    super do
      if !@ui.nil? && @ui.save
        # rubocop:disable-next Layout/LineLength
        flash[:notice] = _('Your account has been successfully linked to your institutional credentials. You will now be able to sign in with them.')
      end
    end
  end

  def destroy # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    oidc_enabled = Rails.configuration.x.oidc.enabled
    id_token = session[:oidc_id_token] if oidc_enabled

    if oidc_enabled && id_token.present?
      sign_out(resource_name)

      session.delete(:oidc_id_token)
      session.delete(:locale)
      set_locale

      oidc_external_url =
        ENV.fetch('OIDC_EXTERNAL_URL', 'http://localhost:8080/keycloak').chomp('/')
      oidc_realm_name = ENV.fetch('OIDC_REALM_NAME', 'dmpopidor')

      realm_url = "#{oidc_external_url}/realms/#{oidc_realm_name}"
      logout_url = "#{realm_url}/protocol/openid-connect/logout"

      params = {
        id_token_hint: id_token,
        post_logout_redirect_uri: root_url
      }

      redirect_to "#{logout_url}?#{params.to_query}",
                  allow_other_host: true
    else
      super do
        session[:locale] = nil
        set_locale
      end
    end
  end
end
