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
    if @document.key?('visibility_ssi')
      case @document['visibility_ssi']
      when 'Public'
        return true
      when 'Yale Community Only'
        return true if current_user || User.on_campus?(request.remote_ip)
      end
    end
    render json: { error: 'unauthorized' }.to_json, status: 401
    false
  end

  # Default implementation, to make it easy to override later
  def search_for_item
    search_service.fetch(params[:id])
  end
end
