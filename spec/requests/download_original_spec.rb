# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Download Original", type: :request do
  let(:thumbnail_size) { "!1200,630" }

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
  let(:private_work) do
    {
      "id": "1234567",
      "title_tesim": ["Fake Work"],
      "visibility_ssi": "Private",
      "child_oids_ssim": ["2222222"]
    }
  end

  before do
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, private_work])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an unauthenticated user' do
    it 'display if set to public' do
      get "/download/tiff/#{public_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:success)
    end
    it 'does not display if set to YCO' do
      get "/download/tiff/#{yale_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:unauthorized)
    end
    it 'does not display if set to private' do
      get "/download/tiff/#{private_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'as an authenticated user' do
    before do
      sign_in user
    end
    it 'display if set to public' do
      get "/download/tiff/#{public_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:success)
    end
    it 'display if set to YCO' do
      get "/download/tiff/#{yale_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:success)
    end
    it 'does not display if set to private' do
      get "/download/tiff/#{private_work[:child_oids_ssim].first}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
