# frozen_string_literal: true

Rails.application.config.after_initialize do
  host = ENV['MANAGEMENT_HOST']
  if Rails.env.production?
    raise 'MANAGEMENT_HOST must be set' if host.blank?
    raise "MANAGEMENT_HOST must be https:// (got #{host.inspect})" unless host.start_with?('https://')
    raise 'OWP_AUTH_TOKEN must be set' if ENV['OWP_AUTH_TOKEN'].blank?
  elsif host.present? && !host.start_with?('https://')
    Rails.logger.warn(
      "MANAGEMENT_HOST is not https:// (got #{host.inspect}) — " \
      'ManagementClient calls will raise NotConfigured. ' \
      'See app/services/management_client.rb (F03).'
    )
  end
end
