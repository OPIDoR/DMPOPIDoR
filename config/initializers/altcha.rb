# frozen_string_literal: true

Altcha.setup do |config|
  config.hmac_key         = ENV.fetch('ALTCHA_HMAC_KEY', 'e532f273ecaaf89faa8a52f4673aa6a3376ae21dcfa5b0728a233c77b058c867')
  config.algorithm        = 'SHA-256'
  config.max_number       = 1_000_000
  config.timeout          = 5.minutes
  config.cache_key_prefix = 'altcha:solution:'
end
