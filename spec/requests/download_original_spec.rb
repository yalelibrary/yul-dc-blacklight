# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Download Original", type: :request, clean: true do
  let(:imgtiff) { 'image/tiff' }
  let(:yale_user) { FactoryBot.create(:user, netid: 'net_id', sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6e', uid: 'sun345') }
  let(:non_yale_user) { FactoryBot.create(:user, sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6f', uid: 'moon678') }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({ "child_oids_ssim": ["5555555"] }) }
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Yale Community Only",
      "child_oids_ssim": ["11111"]
    }
  end
  let(:owp_work_without_permission) do
    {
      "id": "1818909",
      "title_tesim": ["[Map of Australia]. [owp-only copy]"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["44444"]
    }
  end
  let(:owp_work_with_permission) do
    {
      "id": "1918909",
      "title_tesim": ["Fictional Work"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["66666"]
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
  let(:not_available_yet_owp) do
    {
      "id": "2345678999",
      "title_tesim": ["Fiction Work"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["77777"]
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
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/44/44/44/44444.tif')
      .to_return(status: 200, body: '')
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/66/66/66/66666.tif')
      .to_return(status: 200, body: '')
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/66/66/66/66666.tif')
      .to_return(status: 200, body: '')
    stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/77/77/77/77777.tif')
      .to_return(status: 404)
    stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/download/tiff/77/77/77/77777.tif')
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
    stub_request(:get, "http://www.example.com/management/api/download/stage/child/77777")
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
        "permission_set_terms_agreed":[1],
        "permissions":[{
          "oid":1918909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z",
          "user_note": "permission.user_note",
          "user_full_name": "request_user.name"}]}')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/sun345")
      .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1918909/sun345")
      .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/2345678999/sun345")
      .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6f')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6f"},
        "permission_set_terms_agreed":[1],
        "permissions":[{
          "oid":1918909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z",
          "user_note": "permission.user_note",
          "user_full_name": "request_user.name"},
          {
          "oid":2345678999,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z",
          "user_note": "permission.user_note",
          "user_full_name": "request_user.name"}
          ]}')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/moon678")
      .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1918909/moon678")
      .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/2345678999/moon678")
      .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, owp_work_with_permission, owp_work_without_permission, private_work, not_available_yet, not_available_yet_owp])
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
    it 'does not display if set to OWP' do
      get "/download/tiff/#{owp_work_without_permission[:child_oids_ssim].first}"
      expect(response).to have_http_status(:unauthorized) # 401
    end
    it 'does not display if set to private' do
      get "/download/tiff/#{private_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:not_found) # 404
    end
  end

  context 'as an authenticated yale user' do
    before do
      sign_in yale_user
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
      it 'display if set to OWP with permission' do
        get "/download/tiff/#{owp_work_with_permission[:child_oids_ssim].first}"
        expect(response).to have_http_status(:success) # 200
        expect(response.content_type).to eq imgtiff
      end
      it 'does not display if set to OWP without permission' do
        get "/download/tiff/#{owp_work_without_permission[:child_oids_ssim].first}"
        expect(response).to have_http_status(:unauthorized) # 401
      end
      it 'does not display if set to private' do
        get "/download/tiff/#{private_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:not_found) # 404
      end
    end
    context 'when file is not present on S3' do
      it 'stages tiff for download when user has viewing access' do
        get "/download/tiff/#{not_available_yet[:child_oids_ssim].first}"
        expect(response).to have_http_status(:see_other) # 303
        expect(response.redirect_url).to eq 'http://www.example.com/download/tiff/3333333/staged'
      end
      it 'does not stage tiff for download when user does not have viewing access' do
        get "/download/tiff/#{not_available_yet_owp[:child_oids_ssim].first}"
        expect(response).to have_http_status(:unauthorized) # 401
      end
    end
    context 'when child object does not exist' do
      it 'presents user with not found message' do
        get '/download/tiff/89'
        expect(response).to have_http_status(:not_found) # 404
      end
    end
  end

  context 'as an authenticated non yale user' do
    before do
      sign_in non_yale_user
    end
    context 'when file is present on S3' do
      it 'display if set to public' do
        get "/download/tiff/#{public_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:success) # 200
        expect(response.content_type).to eq imgtiff
      end
      it 'does not display if set to YCO' do
        get "/download/tiff/#{yale_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:unauthorized) # 401
      end
      it 'display if set to OWP with permission' do
        get "/download/tiff/#{owp_work_with_permission[:child_oids_ssim].first}"
        expect(response).to have_http_status(:success) # 200
        expect(response.content_type).to eq imgtiff
      end
      it 'does not display if set to OWP without permission' do
        get "/download/tiff/#{owp_work_without_permission[:child_oids_ssim].first}"
        expect(response).to have_http_status(:unauthorized) # 401
      end
      it 'does not display if set to private' do
        get "/download/tiff/#{private_work[:child_oids_ssim].first}"
        expect(response).to have_http_status(:not_found) # 404
      end
    end
    context 'when file is not present on S3' do
      it 'stages tiff for download' do
        get "/download/tiff/#{not_available_yet_owp[:child_oids_ssim].first}"
        expect(response).to have_http_status(:see_other) # 303
        expect(response.redirect_url).to eq 'http://www.example.com/download/tiff/77777/staged'
      end
    end
  end
end
