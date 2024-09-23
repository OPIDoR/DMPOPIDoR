# Use this hook to configure contact mailer.
ContactUs.setup do |config|

  # ==> Mailer Configuration

  # Configure the e-mail address which email notifications should be sent from.
  # If emails must be sent from a verified email address you may set it here.
  # Example:
  # config.mailer_from = "contact@please-change-me.com"
  config.mailer_from = ENV.fetch('MAILER_FROM', 'example@email.address')

  # Configure the e-mail address which should receive the contact form email notifications.
  config.mailer_to = ENV.fetch('MAILER_TO', 'example@email.address')

  # ==> Form Configuration

  # Configure the form to ask for the users name.
  config.require_name = ENV.fetch('MAILER_REQUIRE_NAME', true).to_s.casecmp('true').zero?

  # Configure the form to ask for a subject.
  config.require_subject = ENV.fetch('MAILER_REQUIRE_SUBJECT', true).to_s.casecmp('true').zero?

  # Configure the form gem to use.
  # Example:
  # config.form_gem = 'formtastic
  # config.form_gem = 'formtastic'
  config.localize_routes = ENV.fetch('MAILER_LOCALIZE_ROUTES', true).to_s.casecmp('true').zero?
end
