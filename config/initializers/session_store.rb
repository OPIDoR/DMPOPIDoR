# frozen_string_literal: true

# Be sure to restart your server when you modify this file.
secure = Rails.env.production?

Rails.application.config.session_store :redis_store,
                                       servers: Rails.configuration.x.dmpopidor.redis_url,
                                       expire_after: 1.day,
                                       key: ENV.fetch('SESSION_STORE_KEY', '_dmp_opidor_session'),
                                       threadsafe: ENV.fetch('SESSION_STORE_THREADSAFE',
                                                             false).to_s.casecmp('true').zero?,
                                       secure: secure
