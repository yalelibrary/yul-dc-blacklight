# frozen_string_literal: true
class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: 'Not found' }, status: :not_found }
      format.any { render_plain_not_found }
    end
  rescue ActionController::UnknownFormat
    render_plain_not_found
  end

  private

  def render_plain_not_found
    render plain: 'Not found', status: :not_found, content_type: 'text/plain'
  end
end
