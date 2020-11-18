# frozen_string_literal: true

# Takes a request for a manifest/oid and stream the JSON for that oid from S3
class ManifestsController < ApplicationController
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
    # TODO A&J - make this real code and not stuff Rob made up
    if reponse.metadata['visibility'] == "public" || (reponse.metadata['visibility'] == "Yale Only" && current_user)
      response.body&.read
    else
      # TODO A&J - burn it all down (or just show a 401 unauthorized message)
    end
  end
end
