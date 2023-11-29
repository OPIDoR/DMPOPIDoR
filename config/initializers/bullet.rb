# frozen_string_literal: true

if defined?(Bullet)
  Bullet.tap do |config|
    config.enable = ENV.fetch('BULLET_ENABLE', true).to_s.casecmp('true').zero?
    # config.alert = true
    config.bullet_logger = ENV.fetch('BULLET_LOGGER', true).to_s.casecmp('true').zero?
    config.console = ENV.fetch('BULLET_CONSOLE', true).to_s.casecmp('true').zero?
    # config.growl = true
    # config.xmpp = { :account  => 'bullets_account@jabber.org',
    #                 :password => 'bullets_password_for_jabber',
    #                 :receiver => 'your_account@jabber.org',
    #                 :show_online_status => true }
    config.rails_logger = ENV.fetch('BULLET_RAILS_LOGGER', true).to_s.casecmp('true').zero?
    # config.honeybadger = true
    # config.bugsnag = true
    # config.airbrake = true
    # config.rollbar = true
    config.add_footer = ENV.fetch('BULLET_ADD_FOOTER', true).to_s.casecmp('true').zero?
    # config.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    # config.stacktrace_excludes = [ 'their_gem', 'their_middleware' ]
    # config.slack = {
    #   webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier'
    # }
  end
end
