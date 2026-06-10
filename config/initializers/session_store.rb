# frozen_string_literal: true

secure = Rails.env.production?
default_key = Rails.env.production? ? "_app_session" : "_blacklight_yul_session"
key = ENV.fetch("SESSION_COOKIE_KEY", default_key)

# Do not force a cookie domain in local/test environments.
# Capybara/request hosts are often not localhost, and a mismatched domain
# prevents the cookie from being sent, which drops session state.
raw_host = ENV["BLACKLIGHT_HOST"].to_s
normalized_host = raw_host.sub(%r{\Ahttps?://}i, '').split(':').first

session_store_options = {
  expire_after: 30.days,
  key: key,
  threadsafe: true,
  secure: secure,
  same_site: :lax,
  httponly: true
}

session_store_options[:domain] = normalized_host if normalized_host.present? && normalized_host != 'localhost' && !Rails.env.test?

Rails.application.config.session_store :cookie_store, **session_store_options
