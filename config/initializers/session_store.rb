# frozen_string_literal: true

secure = Rails.env.production?
key = Rails.env.production? ? "_app_session" : "_app_session_#{Rails.env}"
domain = ENV.fetch("BLACKLIGHT_HOST", "localhost")

Rails.application.config.session_store :cookie_store,
                                       expire_after: 30.days,
                                       key: key,
                                       domain: domain,
                                       threadsafe: true,
                                       secure: secure,
                                       same_site: :lax,
                                       httponly: true
