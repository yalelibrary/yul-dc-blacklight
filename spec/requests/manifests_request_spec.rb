# frozen_string_literal: true
require 'rails_helper'
# WebMock.allow_net_connect!

RSpec.describe 'Manifests', type: :request, clean: true do
  let(:user) { FactoryBot.create(:user) }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY }
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Yale Community Only"
    }
  end
  # let(:cas) { WORK_WITH_YALE_ONLY_VISIBILITY }

  before do
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/manifests/95/20/55/09/2055095.json')
      .to_return(
        status: 200,
        body: JSON.generate(public_work),
        headers: { "Content-Type": "application/json" }
      )
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/manifest/09/16/18/90/1618909.json')
      .to_return(
        status: 200,
        body: JSON.generate(yale_work),
        headers: { "Content-Type": "application/json" }
      )

    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work])
    solr.commit
  end

  around do |example|
    original_sample_bucket = ENV['SAMPLE_BUCKET']
    ENV['SAMPLE_BUCKET'] = 'yul-test-samples'
    example.run
    ENV['SAMPLE_BUCKET'] = original_sample_bucket
  end

  context 'as an unauthenticated user' do
    it 'display if set to public' do
      get '/manifests/2055095'
      manifest = JSON.parse(response.body)

      expect(manifest['visibility_ssi']).to eq('Public')
      expect(manifest['title_tesim'][0]).to eq('A General dictionary of the English language')
    end

    it 'do not display if set to yale only' do
      get '/manifests/16189097-yale'
      manifest = JSON.parse(response.body)

      expect(manifest['error']).to eq('not-found')
    end
  end

  context 'as an authenticated user' do
    before do
      sign_in user
    end

    it 'display if set to public' do
      get '/manifests/2055095'
      manifest = JSON.parse(response.body)

      expect(manifest['visibility_ssi']).to eq('Public')
      expect(manifest['title_tesim'][0]).to eq('A General dictionary of the English language')
    end

    it 'display if set to yale only' do
      get '/manifests/16189097-yale'
      manifest = JSON.parse(response.body)
      byebug

      expect(manifest['visibility_ssi']).to eq('Yale Community Only')
      expect(manifest['title_tesim'][0]).to eq('[Map of China]. [yale-only copy]')
    end
  end
end
