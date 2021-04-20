# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include HttpAuthConcern

  layout :determine_layout if respond_to? :layout

  rescue_from Blacklight::Exceptions::RecordNotFound do
    # redirect_to 'errors#not_found', status: 404
    render template: 'errors/not_found'
    # render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end

  def landing
    render layout: false
  end
end
