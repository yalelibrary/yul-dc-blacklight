# frozen_string_literal: true

# Takes a request for an image and passes back the hidden proxy url for nginx to serve
class IiifController < ApplicationController
  include Blacklight::Catalog
  include CheckAuthorization

  def show
    redirect_to request.original_fullpath.gsub('check', 'authorized')
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
