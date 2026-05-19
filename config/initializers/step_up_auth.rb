# frozen_string_literal: true

# Records the original sign-in time on the session. Fires on every sign-in path
# (omniauth, Devise test helpers, etc.) but not on per-request user fetches.
Warden::Manager.after_set_user except: :fetch do |_user, auth, _opts|
  auth.request.session[:signed_in_at] = Time.current.to_i
end
