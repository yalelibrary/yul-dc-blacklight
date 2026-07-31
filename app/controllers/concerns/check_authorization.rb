# frozen_string_literal: true

module CheckAuthorization
  extend ActiveSupport::Concern
  include AccessHelper

  def check_authorization
    # checking authorization
    Rails.logger.warn("starting authorization check for #{sanitize_header_value_for_logs(request.env['HTTP_X_ORIGIN_URI'])}")
    @response, @document = search_for_item
    if @document.blank?
      render_not_found
      return false
    end
    return true if client_can_view_digital?(@document)
    render_access_denied
    false
  end

  # Default implementation, to make it easy to override later
  def search_for_item
    search_service.fetch(params[:id], { fl: ['visibility_ssi', 'id'] })
  end

  private

  def render_access_denied
    return render_not_found if current_user.blank?
    render json: { error: 'forbidden' }.to_json, status: :forbidden
  end

  def render_not_found
    render json: { error: 'not-found' }.to_json, status: :not_found
  end
end
