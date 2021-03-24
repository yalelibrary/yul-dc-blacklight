# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Iiifs", type: :request do
  let(:user) { FactoryBot.create(:user) }
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

  before do
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, no_visibility_work])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an unauthenticated user' do
    describe 'GET /show' do
      let(:logger_mock) { instance_double("Rails.logger").as_null_object }
      it 'redirects to HTML page' do
        allow(Rails.logger).to receive(:warn) { :logger_mock }
        get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/!200,200/0/default.jpg" }
        expect(response).to have_http_status(:success)
        expect(Rails.logger).to have_received(:warn)
          .with("starting search for item for /iiif/2/5555555/full/!200,200/0/default.jpg")
          .with("starting authorization check for /iiif/2/5555555/full/!200,200/0/default.jpg")
          .with("starting client can view digital check for /iiif/2/5555555/full/!200,200/0/default.jpg")
      end
    end

    it 'display if set to public' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'do not display if set to yale only' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/1111111/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an unauthorized response if there is no visibility key' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/2222222/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns an unauthorized response if there child is not found' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/9328239/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'as an authenticated user' do
    before do
      sign_in user
    end
    it 'display if set to public' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/5555555/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'do not display if set to yale only' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/1111111/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:success)
    end

    it 'returns an unauthorized response if there is no visibility key' do
      get "/check-iiif", headers: { 'X-Origin-URI' => "/iiif/2/2222222/full/!200,200/0/default.jpg" }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
