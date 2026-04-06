# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include HttpAuthConcern

  before_action :ensure_guest_uid_authentication_key

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

  def ensure_guest_uid_authentication_key
    # skip if user is logged in
    return if current_user.present?
    # skip for non-HTML requests to prevent breaking CSS and JS assets
    return unless request.format.html? && !request.xhr?
    # create a unique guest UID if necessary
    guest_uid_authentication_key(session["warden.user.user.key"])
  end

  # Needed for guest user authentication. Devise expects the authentication key to be present, but we want to allow it to be nil for non-guest users.
  # This method ensures that only keys starting with "guest" are considered valid, and generates a unique guest UID if the key is nil or invalid.
  # rubocop:disable Lint/UselessAssignment
  def guest_uid_authentication_key(key)
    key &&= nil unless /^guest/.match?(key.to_s)
    key ||= "guest_" + Digest::UUID.uuid_v5(Digest::UUID::DNS_NAMESPACE, ENV['BLACKLIGHT_HOST'] || 'localhost')
    session["warden.user.user.key"] = key
  end
  # rubocop:enable Lint/UselessAssignment
end
