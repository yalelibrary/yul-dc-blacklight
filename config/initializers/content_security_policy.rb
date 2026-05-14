# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
enforce_envs = %w[production staging test]
if enforce_envs.include?(ENV['RAILS_ENV'])
  Rails.application.configure do
    config.content_security_policy do |policy|
      policy.default_src     :self, :https
      policy.font_src        :self, 'static.library.yale.edu'
      policy.img_src         :self, :https, :data, "#{ENV['IIIF_IMAGE_BASE_URL']}/"
      policy.object_src      :none
      policy.script_src      :self, 'siteimproveanalytics.com', 'www.googletagmanager.com'
      policy.script_src_elem :self, 'siteimproveanalytics.com', 'www.googletagmanager.com'
      # Inline event handler attributes (onclick=, onchange=, etc.) cannot be authorized
      # by nonces or hashes, so we block them entirely. All inline handlers have been
      # migrated to addEventListener-based bindings.
      policy.script_src_attr :none
      policy.style_src       :self, :unsafe_inline
      policy.style_src_attr  :self, :unsafe_inline
      policy.style_src_elem  :self, :unsafe_inline, "#{ENV['IIIF_IMAGE_BASE_URL']}/"
      policy.connect_src     :self, 'banner.library.yale.edu', 'www.google-analytics.com',
                             'region1.google-analytics.com', "#{ENV['IIIF_IMAGE_BASE_URL']}/"

      # Specify URI for violation reports
      unless ENV['CLUSTER_NAME'] == 'local'
        policy.report_uri lambda {
                            "https://api.honeybadger.io/v1/browser/csp?api_key=#{ENV['HONEYBADGER_API_KEY_BLACKLIGHT']}&report_only=true&env=#{ENV['CLUSTER_NAME']}"
                          }
      end
    end

    # Rails' default per-request random nonce. Memoized on the request env, so all
    # `nonce: true` / `content_security_policy_nonce` references within a single
    # request share the same value but it differs across requests.
    config.content_security_policy_nonce_generator  = ->(_request) { SecureRandom.base64(16) }

    # script-src-attr is intentionally omitted from this list — there is no syntax
    # for nonces on inline event-handler attributes, and adding script-src-attr here
    # would cause CSP3 browsers to ignore :unsafe_inline on that directive (which we
    # already set to :none). script-src is listed as a fallback for older browsers
    # that don't honor script-src-elem.
    config.content_security_policy_nonce_directives = %w[script-src script-src-elem]
  end
end
