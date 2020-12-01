# frozen_string_literal: true

# Takes a request for a manifest/oid and stream the JSON for that oid from S3
class ManifestsController < ApplicationController
  include CheckAuthorization
  include Blacklight::Catalog

  def show
    remote_path = pairtree_path
    response.set_header('Access-Control-Allow-Origin', '*')
    render json: download_from_s3(remote_path)
  rescue ArgumentError
    render json: { error: 'unauthorized' }.to_json, status: 401
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
end
