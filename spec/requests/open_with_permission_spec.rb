# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Open with Permission", type: :request, clean: true do
  let(:user) { FactoryBot.create(:user, netid: "net_id", sub: "123") }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({ "child_oids_ssim": ["5555555"] }) }
  let(:owp_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["11111"]
    }
  end

  around do |example|
    original_download_bucket = ENV['S3_DOWNLOAD_BUCKET_NAME']
    original_management_url = ENV['MANAGEMENT_HOST']
    ENV['S3_DOWNLOAD_BUCKET_NAME'] = 'yul-test-samples'
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    example.run
    ENV['S3_DOWNLOAD_BUCKET_NAME'] = original_download_bucket
    ENV['MANAGEMENT_HOST'] = original_management_url
  end

  before do
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/123')
      .to_return(status: 200, body: '{"timestamp":"2023-11-02","user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},"permission_set_terms_agreed":[],"permissions":[{"oid":1618909,"permission_set":1,"permission_set_terms":1,"request_status":null,"request_date":"2023-11-02T20:23:18.824Z","access_until":"2024-11-02T20:23:18.824Z"}]}', headers: [])
    solr = Blacklight.default_index.connection
    solr.add([public_work, owp_work])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an authenticated user' do
    before do
      sign_in user
    end
    it 'can retrieve api information from management' do
      get "/catalog/1618909"
      expect(response).to have_http_status(:success)
    end
  end
end