# frozen_string_literal: true

# Base controller logic
class ApplicationController < ActionController::Base
  # Set Static Pages to use in navigation
  before_action :set_nav_static_pages

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Look for template overrides before rendering
  before_action :prepend_view_paths

  before_action :set_locale

  after_action :store_location

  include GlobalHelpers
  include Pundit::Authorization
  helper_method GlobalHelpers.instance_methods

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # When we are in production reroute Record Not Found errors to the branded 404 page
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def current_org
    current_user.org
  end

  def user_not_authorized
    if user_signed_in?
      # redirect_to plans_url, alert: _("You are not authorized to perform this action.")
      msg = _('You are not authorized to perform this action.')
      render_respond_to_format_with_error_message(msg, plans_url, 403, nil)
    else
      # redirect_to root_url, alert: _("You need to sign in or sign up before continuing.")
      msg = _('You need to sign in or sign up before continuing.')
      render_respond_to_format_with_error_message(msg, root_url, 401, nil)
    end
  end

  # Sets I18n locale for every request made
  def set_locale
    I18n.locale = current_locale
  end

  def current_locale
    @current_locale ||= session[:locale].present? ? session[:locale] : I18n.default_locale
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last
    # visited.
    # don't store ajax calls
    unless ['/users/sign_in',
            '/users/sign_up',
            '/users/password',
            '/users/invitation/accept'].any? { |ur| request.fullpath.include?(ur) } || request.xhr?
      session[:previous_url] = request.fullpath
    end
  end

  def after_sign_in_path_for(_resource)
    plans_path(anchor: 'content')
  end

  def after_sign_up_path_for(_resource)
    referer_path = URI(request.referer).path unless request.referer.nil?
    if from_external_domain? ||
       referer_path.eql?(new_user_session_path) ||
       referer_path.nil?
      root_path
    else
      request.referer
    end
  end

  def after_sign_in_error_path_for(_resource)
    (from_external_domain? ? root_path : request.referer || root_path)
  end

  def after_sign_up_error_path_for(_resource)
    (from_external_domain? ? root_path : request.referer || root_path)
  end

  def authenticate_admin!
    # currently if admin has any super-admin task, they can view the super-admin
    unless user_signed_in? && (current_user.can_add_orgs? ||
                               current_user.can_change_org? ||
                               current_user.can_super_admin?)
      redirect_to root_path
    end
  end

  def failure_message(obj, action = 'save')
    format(_('Unable to %{action} the %{object}. %{errors}'),
           object: obj_name_for_display(obj),
           action: action || 'save', errors: errors_for_display(obj))
  end

  def success_message(obj, action = 'saved')
    format(_('Successfully %{action} the %{object}.'), object: obj_name_for_display(obj), action: action || 'save')
  end

  def errors_for_display(obj)
    return '' unless obj.present? && obj.errors.any?

    msgs = obj.errors.full_messages.uniq.collect { |msg| "<li>#{msg}</li>" }
    "<ul>#{msgs.join}</li></ul>"
  end

  # Added Research output Support
  # rubocop:disable Metrics/AbcSize
  def obj_name_for_display(obj)
    display_name = {
      ApiClient: _('API client'),
      ResearchOutput: _('research output'),
      ExportedPlan: _('plan'),
      GuidanceGroup: _('guidance group'),
      Note: _('comment'),
      Org: _('organisation'),
      Perm: _('permission'),
      Pref: _('preferences'),
      Department: _('department'),
      User: obj == current_user ? _('profile') : _('user'),
      QuestionOption: _('question option'),
      MadmpSchema: _('schema'),
      Registry: _('registry'),
      RegistryValue: _('registry value')
    }
    if obj.respond_to?(:customization_of) && obj.send(:customization_of).present?
      display_name[:Template] = 'customization'
    end
    display_name[obj.class.name.to_sym] || obj.class.name.downcase || 'record'
  end
  # rubocop:enable Metrics/AbcSize

  # Override rails default render action to look for a branded version of a
  # template instead of using the default one. If no override exists, the
  # default version in ./app/views/[:controller]/[:action] will be used
  #
  # The path in the app/views/branded/ directory must match the the file it is
  # replacing. For example:
  #  app/views/branded/layouts/_header.html.erb -> app/views/layouts/_header.html.erb
  def prepend_view_paths
    prepend_view_path Rails.root.join('app', 'views', 'branded')
  end

  ##
  # Sign out of Shibboleth SP local session too.
  # -------------------------------------------------------------
  def after_sign_out_path_for(resource_or_scope)
    url = "#{Rails.configuration.x.shibboleth&.logout_url}#{root_url}"
    return url if Rails.configuration.x.shibboleth&.enabled

    super
  end
  # -------------------------------------------------------------

  def from_external_domain?
    if request.referer.present?
      referer = URI.parse(request.referer)
      home = URI.parse(root_url)
      referer.host != home.host
    else
      false
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[firstname surname org_id])
  end

  def render_not_found(exception)
    msg = _('Record Not Found') + ": #{exception.message}"
    render_respond_to_format_with_error_message(msg, root_url, 404, exception)
  end

  def render_respond_to_format_with_error_message(msg, url_or_path, http_status, exception)
    Rails.logger.error msg
    Rails.logger.error exception&.backtrace if exception.present?

    respond_to do |format|
      # Redirect use to the path and display the error message
      format.html { redirect_to url_or_path, alert: msg }
      # Render the JSON error message (using API V1)
      format.json do
        @payload = { errors: [msg] }
        render '/api/v1/error', status: http_status
      end
    end
  end

  # Set Static Pages collection to use in navigation
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def set_nav_static_pages
    @nav_static_pages = []

    query = '
        query {
          static_pages(filter: { status: { _eq: "published" } }) {
            path,
            inMenu,
            translations {
              languages_code {
                code
              }
              title
            }
          }
        }
      '

    begin
      resp = HTTParty.post("#{Rails.configuration.x.directus.url}/graphql",
                           body: { query: query }.to_json,
                           headers: { 'Content-Type' => 'application/json' })
    rescue StandardError
      return @nav_static_pages
    end

    return @nav_static_pages unless resp.present? && resp.code == 200

    resp = JSON.parse(resp.body)

    pages = resp['data']['static_pages']&.map do |page|
      page_translation = page['translations']
      {
        'path' => page['path'],
        'inMenu' => page['inMenu'],
        'title' => reduce_translations(page_translation, 'title')
      }
    end

    return @nav_static_pages if pages.nil?

    @nav_static_pages = pages
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def reduce_translations(translations, field)
    translations.reduce({}) do |result, translation|
      result.merge(
        translation['languages_code']['code'] => translation[field]
      )
    end
  end
end
