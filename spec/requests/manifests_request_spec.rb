# frozen_string_literal: true

require 'rails_helper'

# WebMock.allow_net_connect!

RSpec.describe 'Manifests', type: :request do
  before do
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/manifests/02/20/41/00/2041002.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
  end

  around do |example|
    original_sample_bucket = ENV['SAMPLE_BUCKET']
    ENV['SAMPLE_BUCKET'] = 'yul-test-samples'
    example.run
    ENV['SAMPLE_BUCKET'] = original_sample_bucket
  end
  describe 'GET /show' do
    it 'returns a json document of the manifest' do
      get '/manifests/2041002'
      expect(response).to have_http_status(:success)
      expect(response.body).to include 'A General dictionary of the English language'
      expect(response.content_type).to eq 'application/json; charset=utf-8'
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end
end
