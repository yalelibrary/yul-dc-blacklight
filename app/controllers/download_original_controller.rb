# frozen_string_literal: true

# Takes a request for an image and passes back the S3 url
class DownloadOriginalController < ApplicationController
  include ActionController::Streaming
  include Blacklight::Catalog
  include CheckAuthorization

  before_action :check_authorization, only: [:tiff]

  def tiff
    if S3Service.exists_in_s3(tiff_pairtree_path)
      send_tiff
    else
      stage_download(params)
      redirect_to search_catalog_path(search_field: 'child_oids_ssim', q: params[:child_oid].to_s), status: 202, notice: 'Item not available for download yet.  Please try again later.'
    end
  end

  private

  def send_tiff
    response.set_header('Content-Type', 'application/tiff')
    response.set_header('X-Robots-Tag', 'noindex')
    response.set_header('Cache-Control', 'no-store')
    client = Aws::S3::Client.new
    client.get_object(bucket: ENV['S3_DOWNLOAD_BUCKET_NAME'], key: tiff_pairtree_path) do |chunk|
      response.stream.write(chunk)
    end
  rescue StandardError => e
    Rails.logger.error("TIFF with id [#{params[:child_oid]}] - error: #{e.message}")
    redirect_to root_path, notice: 'There was an error downloading the file.  Please try again later.'
  ensure
    response.stream.close
  end

  def stage_download(params)
    Rails.logger.info("TIFF with id [#{params[:child_oid]}] not found - staging for download.")
    stage_params = { oid: params[:child_oid] }
    url = URI.parse("#{root_url}management/api/download/stage/child/#{params[:child_oid]}")
    req = Net::HTTP::Post.new(url.path)
    req.form_data = stage_params
    con = Net::HTTP.new(url.host, url.port)
    con.start { |http| http.request(req) }
  end

  def tiff_pairtree_path
    pairtree = Partridge::Pairtree.oid_to_pairtree(params[:child_oid])
    File.join('download', 'tiff', pairtree, "#{params[:child_oid]}.tif")
  end

  def search_for_item
    child_oid = params[:child_oid]
    search_state[:q] = { child_oids_ssim: child_oid }
    search_state[:rows] = 1
    search_service_class.new(config: blacklight_config, search_state: search_state, user_params: search_state.to_h, **search_service_context)
    response, document = search_service.search_results
    [response, document.first]
  end
end
