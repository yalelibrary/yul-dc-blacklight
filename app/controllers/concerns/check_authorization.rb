# frozen_string_literal: true

module CheckAuthorization
  extend ActiveSupport::Concern
  include AccessHelper

  included do
    before_action :check_authorization
  end

  def check_authorization
    @response, @document = search_for_item
    if @document.blank?
      render json: { error: 'not-found' }.to_json, status: 404
      return false
    end
    return true if client_can_view_digital?(@document)
    render json: { error: 'unauthorized' }.to_json, status: 401
    false
  end

  # Default implementation, to make it easy to override later
  def search_for_item
    search_service.fetch(params[:id])
  end
end
