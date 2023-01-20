# frozen_string_literal: true

# Takes a request for an image and passes back the S3 url
class DownloadOriginalController < ApplicationController
  include ActionController::Streaming
  include Blacklight::Catalog
  include CheckAuthorization

  before_action :check_authorization

  def tiff
    send_tiff
  end

  def downloading
    send_file 'public/downloading.html', disposition: 'inline', type: 'text/html; charset=utf-8', status: 202
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
  rescue Aws::S3::Errors::NotFound => e
    stage_download(params, e)
  rescue Aws::S3::Errors::NoSuchKey => e
    stage_download(params, e)
  rescue StandardError => e
    Rails.logger.error("TIFF with id [#{params[:child_oid]}] - error: #{e.message}")
    redirect_to root_path
  ensure
    response.stream.close
  end

  def stage_download(params, e)
    Rails.logger.error("TIFF with id [#{params[:child_oid]}] not found - staging for download: #{e.message}")
    stage_params = { oid: params[:child_oid] }
    url = URI.parse("https://#{root_path}/management/api/download/stage/child/#{params[:child_oid]}")
    req = Net::HTTP::Post.new(url.path)
    req.form_data = stage_params
    req.basic_auth url.user, url.password if url.user
    con = Net::HTTP.new(url.host, url.port)
    con.use_ssl = true
    con.start { |http| http.request(req) }
    redirect_to '/download_original/downloading.html', status: 202
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
