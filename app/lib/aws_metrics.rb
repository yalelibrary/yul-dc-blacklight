# frozen_string_literal: true

# Sends metrics to AWS
class AwsMetrics
  METRIC_NAMESPACE = 'DCS'
  METRIC_NAME = 'Download'
  METRIC_DIMENSION_CLUSTER = 'Cluster'
  METRIC_DIMENSION_DOWNLOAD_FILE_TYPE = 'FileType'
  METRIC_FEATURE_FLAG = '|BLACKLIGHT_AWS_METRICS|'
  # Class names of jobs allowed to generate metrics
  LOGGABLE_JOBS = %w[TIFF PDF].freeze

  def initialize
    @cloudwatch_client = Aws::CloudWatch::Client.new
    @metrics_enabled = ENV['FEATURE_FLAGS']&.include? METRIC_FEATURE_FLAG
    @cluster_name = ENV['CLUSTER_NAME'] || "unknown"
  end

  # rubocop:disable Metrics/MethodLength
  def publish_download_metric_data(file_type)
    unless @metrics_enabled
      Rails.logger.debug "[AwsMetrics] Cloudwatch logging feature flag is not enabled."
      return
    end
    unless LOGGABLE_JOBS.include? file_type
      Rails.logger.debug "[AwsMetrics] Download file type #{file_type} not loggable to Cloudwatch"
      return
    end
    Rails.logger.debug "[AwsMetrics] #{Time.now.utc} Download #{file_type}"
    @cloudwatch_client.put_metric_data(
      namespace: METRIC_NAMESPACE,
      metric_data: [
        {
          metric_name: METRIC_NAME,
          dimensions: [
            {
              name: METRIC_DIMENSION_CLUSTER,
              value: @cluster_name
            },
            {
              name: METRIC_DIMENSION_DOWNLOAD_FILE_TYPE,
              value: file_type
            }
          ],
          value: 1,
          unit: 'Count'
        }
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength
end
