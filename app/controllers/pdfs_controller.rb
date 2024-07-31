# frozen_string_literal: true

# Takes a request for a manifest/oid and stream the JSON for that oid from S3
class PdfsController < ApplicationController
  include ActionController::Live
  include Blacklight::Catalog
  include CheckAuthorization

  before_action :check_authorization

  def show
    send_pdf
  end

  def not_found
    send_file 'public/not_found.html', disposition: 'inline', type: 'text/html; charset=utf-8', status: 404
  end

  private

  def send_pdf
    log_download
    response.set_header('Content-Type', 'application/pdf')
    response.set_header('X-Robots-Tag', 'noindex')
    response.set_header('ETag', S3Service.etag(pdf_pairtree_path, ENV['S3_SOURCE_BUCKET_NAME']))
    client = Aws::S3::Client.new
    client.get_object(bucket: ENV['S3_SOURCE_BUCKET_NAME'], key: pdf_pairtree_path) do |chunk|
      response.stream.write(chunk)
    end
  rescue StandardError => e
    Rails.logger.error("Error reading PDF with id [#{params[:id]}]: #{e.message}")
    redirect_to '/pdfs/not_found.html'
  ensure
    response.stream.close
  end

  def log_download
    AwsMetrics.new.publish_download_metric_data("PDF")
  rescue StandardError => e
    Rails.logger.error("Error logging PDF download to Cloudwatch: #{e.message}")
  end

  def pdf_pairtree_path
    pairtree = Partridge::Pairtree.oid_to_pairtree(params[:id])
    File.join('pdfs', pairtree, "#{params[:id]}.pdf")
  end
end
