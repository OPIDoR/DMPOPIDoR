# frozen_string_literal: true

# Mailer methods for all emails
class UserMailer < ActionMailer::Base
  prepend_view_path 'app/views/branded/'

  include MailerHelper
  helper MailerHelper
  helper FeedbacksHelper

  default from: Rails.configuration.x.organisation.email

  # rubocop:disable Metrics/AbcSize
  def welcome_notification(user)
    @user           = user
    @username       = @user.name
    @email_subject  = format(_('Query or feedback related to %{tool_name}'), tool_name: tool_name)
    # Override the default Rails route helper for the contact_us page IF an alternate contact_us
    # url was defined in the dmproadmap.rb initializer file
    @contact_us     = Rails.application.config.x.organisation.contact_us_url || contact_us_url
    @helpdesk_email = helpdesk_email(org: @user.org)

    I18n.with_locale I18n.default_locale do
      mail(to: @user.email,
           subject: format(_('Welcome to %{tool_name}'), tool_name: tool_name))
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def question_answered(data, user, answer, _options_string)
    @user           = user
    @username       = @user.name
    @answer         = answer
    @question_title = @answer.question.text.to_s
    @plan_title     = @answer.plan.title.to_s
    @template_title = @answer.plan.template.title.to_s
    @data           = data
    @recipient_name = @data['name'].to_s
    @message        = @data['message'].to_s
    @answer_text    = @options_string.to_s
    @helpdesk_email = helpdesk_email(org: @user.org)

    I18n.with_locale I18n.default_locale do
      mail(to: data['email'],
           subject: data['subject'])
    end
  end
  # rubocop:enable Metrics/AbcSize

  # CHANGES
  # Changed subject text
  # Mail is sent with user's locale
  # rubocop:disable Metrics/AbcSize
  def sharing_notification(role, user, inviter:)
    @role       = role
    @user       = user
    @user_email = @user.email
    @username   = @user.name
    @inviter    = inviter
    @link       = url_for(action: 'show', controller: 'plans', id: @role.plan.id)
    @helpdesk_email = helpdesk_email(org: @user.org)

    I18n.with_locale current_locale(@user) do
      mail(to: @role.user.email,
           subject: format(_('%{user_name} has shared a Data Management Plan with you in %{tool_name}'),
                           user_name: @inviter.name(false), tool_name: tool_name))
    end
  end
  # rubocop:enable Metrics/AbcSize

  # CHANGES
  # Mail is sent with user's locale
  # rubocop:disable Metrics/AbcSize
  def permissions_change_notification(role, user)
    return unless user.active?

    @role       = role
    @plan_title = @role.plan.title
    @user       = user
    @recepient  = @role.user
    @messaging  = role_text(@role)
    @helpdesk_email = helpdesk_email(org: @user.org)

    I18n.with_locale current_locale(role.user) do
      mail(to: @role.user.email,
           subject: format(_('Changed permissions on a Data Management Plan in %{tool_name}'), tool_name: tool_name))
    end
  end
  # rubocop:enable Metrics/AbcSize

  # CHANGES
  # Mail is sent with user's locale
  def plan_access_removed(user, plan, current_user)
    return unless user.active?

    @user         = user
    @plan         = plan
    @current_user = current_user
    @helpdesk_email = helpdesk_email(org: @plan.org)

    I18n.with_locale current_locale(@user) do
      mail(to: @user.email,
           subject: format(_('Permissions removed on a DMP in %{tool_name}'), tool_name: tool_name))
    end
  end

  # CHANGES
  # Mail is sent with user's locale
  def feedback_notification(recipient, plan, requestor)
    return unless recipient.active?

    @user           = requestor
    @plan           = plan
    @recipient      = recipient
    @recipient_name = @recipient.name(false)
    @requestor_name = @user.name(false)
    @plan_name      = @plan.title
    @helpdesk_email = helpdesk_email(org: @plan.org)

    I18n.with_locale current_locale(recipient) do
      mail(to: @recipient.email,
           subject: format(_('%{user_name} has requested feedback on a %{tool_name} plan'),
                           tool_name: tool_name, user_name: @user.name(false)))
    end
  end

  # CHANGES
  # Mail is sent with user's locale
  # sender is org's user contact email or no-reply
  # rubocop:disable Metrics/AbcSize
  def feedback_complete(recipient, plan, requestor)
    return unless recipient.active?

    @requestor_name = requestor.name(false)
    @user           = recipient
    @recipient_name = @user.name(false)
    @plan           = plan
    @phase          = @plan.phases.first
    @plan_name      = @plan.title
    @helpdesk_email = helpdesk_email(org: @plan.org)

    I18n.with_locale current_locale(recipient) do
      sender = Rails.configuration.x.organisation.do_not_reply_email ||
               Rails.configuration.x.organisation.email

      mail(to: recipient.email,
           from: sender,
           subject: format(_('%{tool_name}: Expert feedback has been provided for %{plan_title}'),
                           tool_name: tool_name, plan_title: @plan.title))
    end
  end
  # rubocop:enable Metrics/AbcSize

  # CHANGES
  # Mail is sent with user's locale
  # rubocop:disable Metrics/AbcSize
  def plan_visibility(user, plan)
    return unless user.active?

    plan.reload

    I18n.with_locale current_locale(user) do
      @user            = user
      @username        = @user.name
      @plan            = plan
      @plan_title      = @plan.title
      @plan_visibility = _(::Plan::VISIBILITY_MESSAGE[@plan.visibility.to_sym])
      @helpdesk_email = helpdesk_email(org: @plan.org)

      mail(to: @user.email,
           subject: format(_('DMP Visibility Changed: %{plan_title}'), plan_title: @plan.title))
    end
  end
  # rubocop:enable Metrics/AbcSize

  # CHANGES
  # Mail is sent with user's locale
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def new_comment(commenter, plan, answer, collaborator)
    return unless commenter.is_a?(User) && plan.is_a?(Plan)

    owner = plan.owner
    return unless owner.present? && owner.active?

    @commenter       = commenter
    @commenter_name  = @commenter.name
    @plan            = plan
    @plan_title      = @plan.title
    @answer          = answer
    @question        = @answer.question
    @question_number = @question.number
    @section_title   = @question.section.title
    @phase_id        = @question.section.phase.id
    research_output  = @answer.research_output
    research_output_description = research_output&.json_fragment&.research_output_description
    @research_output_name = research_output_description.data['title']
    @phase_link = if plan.structured?
                    url_for(action: 'structured_edit', controller: 'plans', id: @plan.id, phase_id: @phase_id,
                            research_output: research_output.id)
                  else
                    url_for(action: 'edit', controller: 'plans', id: @plan.id, phase_id: @phase_id)
                  end
    @helpdesk_email = helpdesk_email(org: @commenter.org)

    I18n.with_locale current_locale(collaborator) do
      @user_name = collaborator.name
      mail(to: collaborator.email,
           subject: format(_('%{tool_name}: A new comment was added to %{plan_title}'), tool_name: tool_name,
                                                                                        plan_title: @plan.title))
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # CHANGES
  # Mail is sent with user's locale
  def admin_privileges(user)
    return unless user.active?

    @user      = user
    @username  = @user.name
    @ul_list   = privileges_list(@user)
    @helpdesk_email = helpdesk_email(org: @user.org)

    I18n.with_locale current_locale(@user) do
      mail(to: user.email,
           subject: format(_('Administrator privileges granted in %{tool_name}'), tool_name: tool_name))
    end
  end

  # rubocop:disable Metrics/AbcSize
  def api_credentials(api_client)
    @api_client = api_client
    return unless @api_client.contact_email.present?

    @api_docs = Rails.configuration.x.application.api_documentation_urls[:v1]

    @name = @api_client.contact_name.present? ? @api_client.contact_name : @api_client.contact_email

    @helpdesk_email = helpdesk_email(org: @api_client.org)

    I18n.with_locale I18n.default_locale do
      mail(to: @api_client.contact_email,
           subject: format(_('%{tool_name} API client created/updated'), tool_name: tool_name))
    end
  end
  # rubocop:enable Metrics/AbcSize

  ##################
  ## NEW METHODS ###
  ##################
  def anonymization_warning(user)
    @user = user
    @end_date = (@user.last_sign_in_at + 5.years).to_date
    @helpdesk_email = helpdesk_email(org: @user.org)
    I18n.with_locale current_locale(@user) do
      mail(to: @user.email, subject:
        format(_('Account expiration in %{tool_name}'), tool_name: tool_name))
    end
  end

  def anonymization_notice(user)
    @user = user
    @helpdesk_email = helpdesk_email(org: @user.org)
    I18n.with_locale current_locale(@user) do
      mail(to: @user.email, subject:
        format(_('Account expired in %{tool_name}'), tool_name: tool_name))
    end
  end

  # rubocop:disable Metrics/AbcSize
  def client_sharing_notification(client_role, user)
    @api_client = client_role.api_client
    return unless @api_client.contact_email.present?

    @client_role = client_role
    @contact_name = @api_client.contact_name.present? ? @api_client.contact_name : @api_client.contact_email
    @user = user

    @link = url_for(action: 'show', controller: '/api/v1/madmp/plans', id: @client_role.plan.id)
    @helpdesk_email = helpdesk_email(org: @api_client.org)
    @api_docs = Rails.configuration.x.application.api_documentation_urls[:v1]
    @grant_id = nil

    @grant_id = @client_role.plan.grant_identifier if @api_client.org&.funder?

    I18n.with_locale I18n.default_locale do
      mail(to: @api_client.contact_email,
           subject: format(_('%{username} has granted access to their Data Management Plan in %{tool_name}'),
                           username: @user.name(false), tool_name: tool_name))
    end
  end
  # rubocop:enable Metrics/AbcSize
end
