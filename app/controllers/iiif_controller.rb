# frozen_string_literal: true

# Takes a request for an image and passes back the hidden proxy url for nginx to serve
class IiifController < ApplicationController
  include Blacklight::Catalog
  include CheckAuthorization

  before_action :check_authorization

  def show
    render plain: 'success', status: :ok
  end

  protected

  # IIIF doesn't just return the oid, find the child, then find the oid from there
  def search_for_item
    Rails.logger.warn("starting search for item for #{request.headers['X-Origin-URI']}")
    child_oid = request.headers['X-Origin-URI'].gsub(/^\/iiif\/2\/(\d+)\/.*/, '\1')
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
end
