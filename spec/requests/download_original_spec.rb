# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Download Original", type: :request, clean: true do
  let(:imgtiff) { 'image/tiff' }
  let(:user) { FactoryBot.create(:user, netid: "net_id") }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({ "child_oids_ssim": ["5555555"] }) }
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Yale Community Only",
      "child_oids_ssim": ["11111"]
    }
  end
  let(:private_work) do
    {
      "id": "1234567",
      "title_tesim": ["Fake Work"],
      "visibility_ssi": "Private",
      "child_oids_ssim": ["2222222"]
    }
  end
  let(:not_available_yet) do
    {
      "id": "2345678",
      "title_tesim": ["Fictional Work"],
      "visibility_ssi": "Public",
      "child_oids_ssim": ["3333333"]
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
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/55/55/55/55/5555555.tif')
      .to_return(status: 200, body: '')
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/55/55/55/55/5555555.tif')
      .to_return(status: 200, body: '')
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/11/11/11/11111.tif')
      .to_return(status: 200, body: '')
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/11/11/11/11111.tif')
      .to_return(status: 200, body: '')
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/22/22/22/22/2222222.tif')
      .to_return(status: 200, body: '')
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/33/33/33/33/3333333.tif')
      .to_return(status: 404)
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/33/33/33/33/3333333.tif')
      .to_return(status: 404)
    stub_request(:get, "http://www.example.com/management/api/download/stage/child/3333333")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '', headers: {})
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, private_work, not_available_yet])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an unauthenticated user' do
    it 'display if set to public' do
      get "/download/tiff/#{public_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:success) # 200
      expect(response.content_type).to eq imgtiff
    end
    it 'does not display if set to YCO' do
      get "/download/tiff/#{yale_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:unauthorized) # 401
    end
    it 'does not display if set to private' do
      get "/download/tiff/#{private_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:not_found) # 404
    end
  end

  context 'as an authenticated user' do
    before do
      sign_in user
    end
    context 'when file is present on S3' do
      it 'display if set to public' do
        get "/download/tiff/#{public_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:success) # 200
        expect(response.content_type).to eq imgtiff
      end
      it 'display if set to YCO' do
        get "/download/tiff/#{yale_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:success) # 200
        expect(response.content_type).to eq imgtiff
      end
      it 'does not display if set to private' do
        get "/download/tiff/#{private_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:not_found) # 404
      end
    end
    context 'when file is not present on S3' do
      it 'presents user with try again message' do
        get "/download/tiff/#{not_available_yet[:child_oids_ssim].first}"
        expect(response).to have_http_status(:see_other) # 303
        expect(response.redirect_url).to eq 'http://www.example.com/download/tiff/3333333/staged'
      end
    end
    context 'when child object does not exist' do
      it 'presents user with not found message' do
        get '/download/tiff/89'
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end
end
