# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include HttpAuthConcern

  layout :determine_layout if respond_to? :layout

  rescue_from Blacklight::Exceptions::RecordNotFound, with: :not_found

  def not_found
    send_file 'public/not_found.html', disposition: 'inline', type: 'text/html; charset=utf-8', status: 404
  end

  def landing
    render layout: false
  end

  def help_guide
    render "/help_guide"
  end

  private

  # Needed for guest user authentication. Devise expects the authentication key to be present.
  # This method generates a unique guest UID if one is not present.
  # rubocop:disable Lint/UselessAssignment
  def guest_uid_authentication_key(key)
    key ||= Digest::UUID.uuid_v5(Digest::UUID::DNS_NAMESPACE, ENV['BLACKLIGHT_HOST'] || 'localhost')
  end
  # rubocop:enable Lint/UselessAssignment
end
