# frozen_string_literal: true

# Takes a request for a manifest/oid and stream the JSON for that oid from S3
class ManifestsController < ApplicationController
  before_action :check_authorization

  def show
    remote_path = pairtree_path
    response.set_header('Access-Control-Allow-Origin', '*')
    render json: download_from_s3(remote_path)
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
    @solr_query = Blacklight.default_index.connection
    solr_connection = @solr_query.connection
    response = solr_connection.get 'select', params: { q: "id:#{params[:id]}" }
    visibility = response.body
    when 'Public'
      return true
    when 'Yale Only'
      if current_user
        return true
      else
        render json: { error: "not-found" }.to_json, status: 404
        return false
      end
    else
      render json: { error: "not-found" }.to_json, status: 404
      return false
    end
  end
end
