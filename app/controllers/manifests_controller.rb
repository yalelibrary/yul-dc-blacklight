# frozen_string_literal: true

# Takes a request for a manifest/oid and stream the JSON for that oid from S3
class ManifestsController < ApplicationController
  before_action :check_authorization
  include Blacklight::Catalog

  def show
    remote_path = pairtree_path
    response.set_header('Access-Control-Allow-Origin', '*')
    render json: download_from_s3(remote_path)
  rescue ArgumentError
    render json: { error: "not-found" }.to_json, status: 404
  end

  private

  def pairtree_path
    pairtree = Partridge::Pairtree.oid_to_pairtree(params[:id])
    File.join('manifests', pairtree, "#{params[:id]}.json")
  end

  def download_from_s3(remote_path)
    client = Aws::S3::Client.new
    response = client.get_object(bucket: ENV['SAMPLE_BUCKET'], key: remote_path)
    response.body&.read
  end

  def check_authorization
    @response, @document = search_service.fetch(params[:id])

    # Handle when the 'visibility_ssi' key doesn't exist on the manifest
    unless @document.key?('visibility_ssi')
      render json: { error: 'not-found' }.to_json, status: 404
      return false
    end

    case @document['visibility_ssi']
    when 'Public'
      true
    when 'Yale Community Only'
      return true if current_user

      render json: { error: 'not-found' }.to_json, status: 404
      false
    end
  end
end
