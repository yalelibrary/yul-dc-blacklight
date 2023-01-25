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

  def self.exists_in_s3(remote_path, bucket = ENV['S3_DOWNLOAD_BUCKET_NAME'])
    object = Aws::S3::Object.new(bucket_name: bucket, key: remote_path)
    object.exists?
  end
end
