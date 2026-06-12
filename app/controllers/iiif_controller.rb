# frozen_string_literal: true

# Takes a request for an image and passes back the hidden proxy url for nginx to serve
class IiifController < ApplicationController
  include Blacklight::Catalog
  include CheckAuthorization

  before_action :check_authorization
  rescue_from ActionController::BadRequest, with: :render_bad_request

  def show
    render plain: 'success', status: :ok
  end

  protected

  # IIIF doesn't just return the oid, find the child, then find the oid from there
  def search_for_item
    origin_uri = request.headers['X-Origin-URI']
    Rails.logger.warn("starting search for item for #{sanitize_header_value_for_logs(origin_uri)}")
    child_oid = parse_child_oid_from_origin_uri!(origin_uri)
    # search_state[:q] = { child_oids_ssim: child_oid }
    search_state[:rows] = 1
    search_service_class.new(config: blacklight_config, search_state: search_state, user_params: search_state.to_h, **search_service_context)
    r, d = search_service.search_results do |builder|
      builder.where(child_oids_ssim: [child_oid])
      builder.processor_chain.delete(:filter_by_visibility)
      builder
    end
    [r, d.first]
  end

  def parse_child_oid_from_origin_uri!(origin_uri)
    raise ActionController::BadRequest, 'Missing X-Origin-URI header' if origin_uri.blank?

    match = origin_uri.match(%r{\A/iiif/2/(\d+)(?:/.*)?\z})
    raise ActionController::BadRequest, 'Malformed X-Origin-URI header' if match.nil?

    match[1]
  end

  def render_bad_request(exception)
    Rails.logger.warn("Bad request in IiifController: #{exception.message}")
    render json: { error: 'bad-request' }, status: :bad_request
  end
end
