# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
secure = ENV.fetch("SESSION_COOKIE_SECURE", Rails.env.production?.to_s).to_s.casecmp('true').zero?

Rails.application.config.session_store :redis_store,
                                       servers: ENV.fetch('REDIS_URL', 'redis://default:changeme@localhost:6379/1'),
                                       expire_after: 1.day,
                                       key: ENV.fetch('SESSION_STORE_KEY', '_dmp_opidor_session'),
                                       threadsafe: ENV.fetch('SESSION_STORE_THREADSAFE',
                                                             false).to_s.casecmp('true').zero?,
                                       secure: secure
