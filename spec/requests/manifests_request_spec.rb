# frozen_string_literal: true
require 'rails_helper'
# WebMock.allow_net_connect!

RSpec.describe 'Manifests', type: :request do
  # before do
  #   stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/manifests/95/20/55/09/2055095.json')
  #     .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2055095.json')).read)
  # end

  let(:user) { FactoryBot.create(:user) }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY }
  let(:yale_work) { WORK_WITH_YALE_ONLY_VISIBILITY }

  before do
    solr = Blacklight.default_index.connection
    solr.add(public_work)
    solr.add(yale_work)
    solr.commit
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/manifests/95/20/55/09/2055095.json')
      .to_return(status: 200, body: '', headers: {})
      # .to_return(status: 200, body: File.open(File.join('spec', 'support', 'solr_documents', 'metadata_cloud_with_visibility.rb')).read)
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
  end

  around do |example|
    original_sample_bucket = ENV['SAMPLE_BUCKET']
    ENV['SAMPLE_BUCKET'] = 'yul-test-samples'
    example.run
    ENV['SAMPLE_BUCKET'] = original_sample_bucket
  end

  context 'as an unauthenticated user' do
    it 'displays if set to public' do
      get '/manifests/2055095.json'
      byebug
      # expect(response.body).to include 'A General dictionary of the English language'
    end

    # it 'does not display if set to yale only' do
    #   get '/manifests/16189097-yale'
    #   expect(page).not_to have_content('[Map of China]. [yale-only copy]')
    # end
  end

  # describe 'GET /show' do
  #   it 'returns a json document of the manifest' do
  #     get '/manifests/2041002'
  #     expect(response).to have_http_status(:success)
  #     expect(response.body).to include 'A General dictionary of the English language'
  #     expect(response.content_type).to eq 'application/json; charset=utf-8'
  #     expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
  #   end
  # end
end
