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

  # For open with permission works
  def create_readable_status(status)
    readable_status = "Pending"
    if status == true
      readable_status = "Approved"
    elsif status == false
      readable_status = "Denied"
    end
    readable_status
  end
end
