# frozen_string_literal: true

module CheckAuthorization
  extend ActiveSupport::Concern
  include AccessHelper

  def check_authorization
    # checking authorization
    @response, @document = search_for_item
    if @document.blank?
      render json: { error: 'not-found' }.to_json, status: :not_found
      return false
    end
    return true if client_can_view_digital?(@document)
    render json: { error: 'unauthorized' }.to_json, status: :unauthorized
    false
  end

  # Default implementation, to make it easy to override later
  def search_for_item
    search_service.fetch(params[:id], { fl: ['visibility_ssi', 'id'] })
  end
end
