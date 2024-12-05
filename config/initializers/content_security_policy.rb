# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header
if ENV["RAILS_ENV"] == 'production' || ENV["RAILS_ENV"] == 'staging'
  Rails.application.configure do
    config.content_security_policy do |policy|
      policy.default_src :self, :https
      policy.font_src    :self, 'static.library.yale.edu'
      policy.img_src     :self, :https, :data, "#{ENV['IIIF_IMAGE_BASE_URL']}/"
      policy.object_src  :none
      policy.script_src  :self, 'siteimproveanalytics.com www.googletagmanager.com'
      policy.script_src_attr  :self, :unsafe_inline, 'www.googletagmanager.com'
      policy.script_src_elem  :self, 'siteimproveanalytics.com www.googletagmanager.com'
      policy.style_src :self
      policy.style_src_elem :self, :unsafe_inline, "#{ENV['IIIF_IMAGE_BASE_URL']}/"
      policy.connect_src :self, "banner.library.yale.edu www.google-analytics.com #{ENV['IIIF_IMAGE_BASE_URL']}/"

      # Specify URI for violation reports
      unless ENV['CLUSTER_NAME'] == 'local'
        policy.report_uri lambda {
                            "https://api.honeybadger.io/v1/browser/csp?api_key=#{ENV['HONEYBADGER_API_KEY_BLACKLIGHT']}&report_only=true&env=#{ENV['CLUSTER_NAME']}"
                          }
      end
    end

    config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }

    config.content_security_policy_nonce_directives = %w[script-src script-src-elem script-src-attr style-src]

    # Report violations without enforcing the policy.
    # config.content_security_policy_report_only = true
  end
end
