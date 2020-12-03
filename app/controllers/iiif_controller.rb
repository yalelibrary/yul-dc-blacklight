# frozen_string_literal: true

# Takes a request for an image and passes back the hidden proxy url for nginx to serve
class IiifController < ApplicationController
  include Blacklight::Catalog
  include CheckAuthorization

  def show
    # authorization has passed by this point, swap the url to authorized and make sure protocol stays http
    authorized_image_url = request.original_fullpath.gsub('check', 'authorized').gsub(/^https:\/\//, 'http://')
    Rails.logger.error("======= Image URL: #{authorized_image_url}")
    redirect_to authorized_image_url
  end

  protected

  # IIIF doesn't just return the oid, find the child, then find the oid from there
  def search_for_item
    child_oid = params[:id].gsub(/^2\/(\d+)\/.*/, '\1')
    search_state[:q] = { child_oids_ssim: child_oid }
    search_state[:rows] = 1
    search_service_class.new(config: blacklight_config, search_state: search_state, user_params: search_state.to_h, **search_service_context)
    r, d = search_service.search_results do |builder|
      builder.processor_chain.delete(:show_only_public_records)
      builder
    end
    [r, d.first]
  end
end
