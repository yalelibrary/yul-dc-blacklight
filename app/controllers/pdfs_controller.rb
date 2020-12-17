# frozen_string_literal: true

# Takes a request for a manifest/oid and stream the JSON for that oid from S3
class PdfsController < ApplicationController
  include ActionController::Streaming
  include Blacklight::Catalog
  include CheckAuthorization

  def show
    send_pdf
  end

  def not_found
    send_file 'public/not_found.html', disposition: 'inline', type: 'text/html; charset=utf-8', status: 404
  end

  private

  def send_pdf
    response.set_header('Content-Type', 'application/pdf')
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

  def pdf_pairtree_path
    pairtree = Partridge::Pairtree.oid_to_pairtree(params[:id])
    File.join('pdfs', pairtree, "#{params[:id]}.pdf")
  end
end
