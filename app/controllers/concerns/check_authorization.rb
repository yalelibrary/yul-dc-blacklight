# frozen_string_literal: true

module CheckAuthorization
  extend ActiveSupport::Concern
  included do
    before_action :check_authorization
  end

  def check_authorization
    @response, @document = search_for_item
    if @document.blank?
      render json: { error: 'not-found' }.to_json, status: 404
      return false
    end

    # Handle when the 'visibility_ssi' key doesn't exist on the manifest
    unless @document.key?('visibility_ssi')
      render json: { error: 'not-found' }.to_json, status: 404
      return false
    end

    case @document['visibility_ssi']
    when 'Public'
      true
    when 'Yale Community Only'
      return true if current_user

      render json: { error: 'not-found' }.to_json, status: 404
      false
    end
  end

  # Default implementation, to make it easy to override later
  def search_for_item
    search_service.fetch(params[:id])
  end
end
