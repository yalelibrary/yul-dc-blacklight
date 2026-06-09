# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn,
  # Identity / PII fields emitted during login and permission requests (see issue #3327).
  # :sub and :uid are anchored so they don't also scrub the catalog's `subject`
  # facet params or identifiers like `druid`/`guid` (filter_parameters matches substrings).
  :email, :user_email, :netid, :user_netid, :user_sub,
  :user_full_name, :user_note, :idtoken, :id_token, :authorization,
  /\Asub\z/i, /\Auid\z/i
]
