# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Iiifs", type: :request do
  let(:thumbnail_size) { "!1200,630" }

  let(:yale_user) { FactoryBot.create(:user, netid: "net_id") }
  let(:owp_user) { FactoryBot.create(:user, netid: 'owp_netid', sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6e') }
  let(:non_yale_user) { FactoryBot.create(:user) }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({ "child_oids_ssim": ["5555555"] }) }
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Yale Community Only",
      "child_oids_ssim": ["1111111"]
    }
  end
  let(:no_visibility_work) do
    {
      "id": "1234567",
      "title_tesim": ["Fake Work"],
      "child_oids_ssim": ["2222222"]
    }
  end
  let(:owp_work) do
    {
      "id": "1818909",
      "title_tesim": ["[Map of Australia]. [owp-only copy]"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["3333333"]
    }
  end

  around do |example|
    original_management_url = ENV['MANAGEMENT_HOST']
    original_token = ENV['OWP_AUTH_TOKEN']
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    ENV['OWP_AUTH_TOKEN'] = 'valid'
    example.run
    ENV['MANAGEMENT_HOST'] = original_management_url
    ENV['OWP_AUTH_TOKEN'] = original_token
  end

  before do
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, no_visibility_work, owp_work])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an unauthenticated user' do
    describe 'GET /show' do
      let(:logger_mock) { instance_double("Rails.logger").as_null_object }
      it 'redirects to HTML page' do
        allow(Rails.logger).to receive(:warn) { :logger_mock }
        get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg" }
        expect(response).to have_http_status(:success)
        expect(Rails.logger).to have_received(:warn)
          .with("starting search for item for /iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg")
          .with("starting authorization check for /iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg")
          .with("starting client can view digital check for /iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg")
      end
    end

    it 'display if set to public' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'do not display if set to yale only' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/1111111/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an unauthorized response if there is no visibility key' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/2222222/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an not found response if there child is not found' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/9328239/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad request when X-Origin-URI header is missing' do
      get "/check-iiif"

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq('error' => 'bad-request')
    end

    it 'returns bad request when X-Origin-URI header is malformed' do
      get "/check-iiif", headers: { 'X-Origin-URI' => 'foo' }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)).to eq('error' => 'bad-request')
    end

    it 'sanitizes X-Origin-URI header values in logs' do
      allow(Rails.logger).to receive(:warn)

      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg\r\nFORGED_LOG_ENTRY" }

      expect(response).to have_http_status(:bad_request)
      expect(Rails.logger).to have_received(:warn)
        .with("starting search for item for /iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg FORGED_LOG_ENTRY")
    end
  end

  context 'as an authenticated yale user' do
    before do
      sign_in yale_user
    end
    it 'display if set to public' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'display if set to yale only' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/1111111/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'returns an unauthorized response if there is no visibility key' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/2222222/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'as an authenticated non yale user' do
    before do
      sign_in non_yale_user
    end
    it 'display if set to public' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'do not display if set to yale only' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/1111111/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an unauthorized response if there is no visibility key' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/2222222/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'as an authenticated user for Open with Permission item' do
    before do
      sign_in owp_user
      stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
        .to_return(status: 200, body: '{ "permissions": [] }', headers: {})
      stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/#{owp_user.netid}")
        .to_return(status: 200, body: '{ "is_admin_or_approver?": false }', headers: {})
    end

    it 'returns unauthorized and calls management APIs through mocked MANAGEMENT_HOST' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/3333333/full/#{thumbnail_size}/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
      expect(WebMock).to have_requested(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e').at_least_once
      expect(WebMock).to have_requested(:get, "http://www.example.com/management/api/permission_sets/1818909/#{owp_user.netid}").at_least_once
    end
  end
end
