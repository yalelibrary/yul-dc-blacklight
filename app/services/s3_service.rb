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
end
