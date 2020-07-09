# frozen_string_literal: true
def http_login
  @env ||= {}
  user = 'admin'
  pw = 'changeme'
  @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
end