require 'rails_helper'

RSpec.describe "Iiifs", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({"child_oids_ssim": ["5555555"]}) }
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
  end

  context 'as an unauthenticated user' do
    it 'display if set to public' do
      get "/check-iiif/2/5555555/full/!200,200/0/default.jpg"

      expect(response).to redirect_to("/authorized-iiif/2/5555555/full/!200,200/0/default.jpg")
    end

    it 'do not display if set to yale only' do
      get "/check-iiif/2/1111111/full/!200,200/0/default.jpg"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns a 404 if there is no visibility key' do
      get "/check-iiif/2/2222222/full/!200,200/0/default.jpg"

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'as an authenticated user' do
    before do
      sign_in user
    end
    it 'display if set to public' do
      get "/check-iiif/2/5555555/full/!200,200/0/default.jpg"

      expect(response).to redirect_to("/authorized-iiif/2/5555555/full/!200,200/0/default.jpg")
    end

    it 'do not display if set to yale only' do
      get "/check-iiif/2/1111111/full/!200,200/0/default.jpg"

      expect(response).to redirect_to("/authorized-iiif/2/1111111/full/!200,200/0/default.jpg")
    end

    it 'returns a 404 if there is no visibility key' do
      get "/check-iiif/2/2222222/full/!200,200/0/default.jpg"

      expect(response).to have_http_status(:not_found)
    end
  end

end
