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
    client = Aws::S3::Client.new
    client.get_object(bucket: ENV['S3_DOWNLOAD_BUCKET_NAME'], key: tiff_pairtree_path) do |chunk|
      response.stream.write(chunk)
    end
    # if user authorized but file does not exist in the S3 bucket
    # need to specify more specific not found error
  rescue StandardError => e
    Rails.logger.error("Error reading TIFF with id [#{params[:id]}]: #{e.message}")
    redirect_to '/download_original/downloading.html'
  ensure
    response.stream.close
  end

  def tiff_pairtree_path
    pairtree = Partridge::Pairtree.oid_to_pairtree(params[:id])
    File.join('download', 'tiff', pairtree, "#{params[:id]}.tif")
  end
end
