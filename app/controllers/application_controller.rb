# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include HttpAuthConcern

  layout :determine_layout if respond_to? :layout

  rescue_from Blacklight::Exceptions::RecordNotFound do
    render template: 'errors/not_found'
  end

  def landing
    render layout: false
  end
end
