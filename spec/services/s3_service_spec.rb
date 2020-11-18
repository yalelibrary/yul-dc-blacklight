# frozen_string_literal: true

require 'rails_helper'
# Intentionally leaving Webmock allow net connect here for ease of testing against live S3 service.
# When testing a new S3 service, verify that you are running only against test buckets, then
# test new service against live S3 service and get tests passing, then comment out
# the following line and stub connections to S3 for the test, so we can run it in CI.
#
# WebMock.allow_net_connect!
RSpec.describe S3Service do
  let(:oid) { 16_172_421 }
  let(:s3_basic_path) { 'https://yul-development-samples.s3.amazonaws.com/manifests/16172421.json' }
  before do
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/testing_test/test.txt')
      .to_return(status: 200, body: 'these are some test words')
  end

  around do |example|
    original_metadata_sample_bucket = ENV['SAMPLE_BUCKET']
    ENV['SAMPLE_BUCKET'] = 'yul-test-samples'
    example.run
    ENV['SAMPLE_BUCKET'] = original_metadata_sample_bucket
  end

  it 'can download metadata from a given bucket' do
    expect(described_class.download('testing_test/test.txt')).to eq 'these are some test words'
  end
end
