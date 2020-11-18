# frozen_string_literal: true

# Connects to Amazon's S3 service
class S3Service
  @client ||= Aws::S3::Client.new

  # Returns the response body text
  def self.download(file_path)
    resp = @client.get_object(bucket: ENV['SAMPLE_BUCKET'], key: file_path)
    resp.body&.read
  rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound, Aws::S3::Errors::BadRequest
    nil
  end

  # Takes a remote S3 bucket path and writes the retrieved image to a local path.
  # It downloads it in chunks because images are very large.
  def self.download_image(remote_path, local_path)
    object = Aws::S3::Object.new(bucket_name: ENV['S3_SOURCE_BUCKET_NAME'], key: remote_path)
    object.download_file(local_path, destination: local_path)
  end
end
