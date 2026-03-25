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

  # Needed for guest user authentication. Devise expects the authentication key to be present, but we want to allow it to be nil for non-guest users.
  # This method ensures that only keys starting with "guest" are considered valid, and generates a unique guest UID if the key is nil or invalid.
  # rubocop:disable Lint/UselessAssignment
  def guest_uid_authentication_key(key)
    key &&= nil unless /^guest/.match?(key.to_s)
    key ||= "guest_" + Array.new(6) { SecureRandom.rand(0..9) }.join
  end
  # rubocop:enable Lint/UselessAssignment
end
