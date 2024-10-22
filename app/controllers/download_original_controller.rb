# frozen_string_literal: true

# Takes a request for an image and passes back the S3 url
class DownloadOriginalController < ApplicationController
  include ActionController::Live
  include Blacklight::Catalog
  include CheckAuthorization

  before_action :check_authorization

  def tiff
    if S3Service.exists_in_s3(tiff_pairtree_path)
      send_tiff
    else
      stage_download
      redirect_to "#{root_url}download/tiff/#{child_oid}/staged", status: :see_other
    end
  end

  def staged
    render 'tiff_staged'
  end

  def available
    if S3Service.exists_in_s3(tiff_pairtree_path)
      render plain: 'true'
    else
      render plain: 'false'
    end
  end

  private

  def send_tiff
    log_download
    response.set_header('Content-Type', 'image/tiff')
    response.set_header('X-Robots-Tag', 'noindex')
    response.set_header('Cache-Control', 'no-store')
    response.set_header('Content-Disposition', "attachment; filename=\"#{child_oid}.tif\"")
    # etag is required for streaming with Rack ETag enabled: https://github.com/rack/rack/issues/1619
    response.set_header('ETag', S3Service.etag(tiff_pairtree_path, ENV['S3_DOWNLOAD_BUCKET_NAME']))
    client = Aws::S3::Client.new
    client.get_object(bucket: ENV['S3_DOWNLOAD_BUCKET_NAME'], key: tiff_pairtree_path) do |chunk|
      response.stream.write(chunk)
    end
  rescue StandardError => e
    Rails.logger.error("TIFF with id [#{child_oid}] - error: #{e.message}")
    redirect_to root_path, notice: 'There was an error downloading the file.  Please try again later.'
  ensure
    response.stream.close
  end

  def log_download
    AwsMetrics.new.publish_download_metric_data("TIFF")
  rescue StandardError => e
    Rails.logger.error("Error logging TIFF download to Cloudwatch: #{e.message}")
  end

  def stage_download
    Rails.logger.info("TIFF with id [#{child_oid}] not found - staging for download.")
    url = URI.parse("http://yul-dc-management-1:3001/management/api/download/stage/child/#{child_oid}")
    req = Net::HTTP::Get.new(url.path)
    con = Net::HTTP.new(url.host, url.port)
    con.start { |http| http.request(req) }
  end

  def tiff_pairtree_path
    pairtree = Partridge::Pairtree.oid_to_pairtree(child_oid)
    File.join('download', 'tiff', pairtree, "#{child_oid}.tif")
  end

  def search_for_item
    search_state[:rows] = 1
    search_service_class.new(config: blacklight_config, search_state: search_state, user_params: search_state.to_h, **search_service_context)
    response, document = search_service.search_results do |builder|
      builder.where(child_oids_ssim: [child_oid])
      builder
    end
    [response, document.first]
  end

  def child_oid
    Integer(params[:child_oid])
  end
end
