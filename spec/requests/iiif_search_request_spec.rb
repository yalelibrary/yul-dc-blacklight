# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Iiif Search", type: :request do
  let(:user) { FactoryBot.create(:user) }

  let(:yale_work) do
    {
      "id": "1234567",
      "title_tesim": ["Fake Work"],
      "child_oids_ssim": ["2222222"],
      "visibility_ssi": "Yale Community Only"
    }
  end
  let(:owp_work) do
    {
      "id": "12345678",
      "title_tesim": ["Fake Work"],
      "child_oids_ssim": ["1111111"],
      "visibility_ssi": "Open with Permission"
    }
  end
  let(:child_work1) do
    {
      "id": "3456",
      "child_fulltext_wstsim": ["This is the ocr text for this document. Paris basketball can you search for it."],
      "child_fulltext_tesim": ["This is the ocr text for this document. Paris basketball can you search for it."],
      "parent_ssi": "1234567"
    }
  end
  let(:child_work2) do
    {
      "id": "3457",
      "child_fulltext_wstsim": ["This is the ocr text for this document. Pakistan baseball can you search for it."],
      "child_fulltext_tesim": ["This is the ocr text for this document. Pakistan baseball can you search for it."],
      "parent_ssi": "1234567"
    }
  end
  let(:child_work3) do
    {
      "id": "345678",
      "child_fulltext_wstsim": ["OwP Fulltext"],
      "child_fulltext_tesim": ["OwP Fulltext"],
      "parent_ssi": "12345678"
    }
  end

  let(:child_work_page_one) do
    {
      "id": "3458",
      "child_fulltext_wstsim": ["Janet walked to the river."],
      "child_fulltext_tesim": ["Janet walked to the river."],
      "parent_ssi": "1234567"
    }
  end
  let(:child_work_page_two) do
    {
      "id": "3459",
      "child_fulltext_wstsim": ["I would not care to guess."],
      "child_fulltext_tesim": ["I would not care to guess."],
      "parent_ssi": "1234567"
    }
  end

  before do
    solr = Blacklight.default_index.connection
    solr.add([yale_work, owp_work, child_work1, child_work2, child_work3,
              child_work_page_one, child_work_page_two])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(true)
  end

  describe "IIIF search" do
    it 'matches document when case does match' do
      get solr_document_iiif_search_path(yale_work[:id], { q: 'basketball' })
      expect(response).to have_http_status(:success)
      hits = JSON.parse(response.body)["hits"]
      expect(hits.count).to eq 1
    end
    it 'matches document when case does not match' do
      get solr_document_iiif_search_path(yale_work[:id], { q: 'BaskeTball' })
      expect(response).to have_http_status(:success)
      hits = JSON.parse(response.body)["hits"]
      expect(hits.count).to eq 1
    end
    it 'does not return any Open with Permission search results' do
      get solr_document_iiif_search_path(owp_work[:id], { q: 'OwP' })
      expect(response).to have_http_status(:not_found)
    end

    it 'returns a hit for every page holding any of the terms' do
      get solr_document_iiif_search_path(yale_work[:id], { q: 'Janet guess' })
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["hits"].count).to eq 2
      canvases = body["resources"].map { |resource| resource["on"] }.join(' ')
      expect(canvases).to include('/canvas/3458')
      expect(canvases).to include('/canvas/3459')
    end

    it 'does not widen matching beyond the requested object' do
      get solr_document_iiif_search_path(yale_work[:id], { q: 'Janet OwP' })
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body["hits"].count).to eq 1
      expect(body["resources"].map { |resource| resource["on"] }.join).not_to include('345678')
    end

    it 'includes proper "on" property in resources' do
      get solr_document_iiif_search_path(yale_work[:id], { q: 'BaskeTball' })
      expect(response).to have_http_status(:success)
      on_id = JSON.parse(response.body)["resources"][0]["on"]
      expect(on_id).to end_with('manifests/oid/1234567/canvas/3456#xywh=0,0,0,0')
    end
  end

  describe "IIIF search suggestion" do
    context "when searching for word not capitalized in original text" do
      it 'returns matches to suggest search when case does match' do
        get solr_document_iiif_suggest_path(yale_work[:id], { q: 'ba' })
        expect(response).to have_http_status(:success)
        term_matches = JSON.parse(response.body)["terms"].map { |term| term["match"] }
        expect(term_matches).to include "baseball"
        expect(term_matches).to include "basketball"
      end

      it 'returns matches to suggest search when case does not match' do
        get solr_document_iiif_suggest_path(yale_work[:id], { q: 'Ba' })
        expect(response).to have_http_status(:success)
        term_matches = JSON.parse(response.body)["terms"].map { |term| term["match"] }
        expect(term_matches).to include "baseball"
        expect(term_matches).to include "basketball"
      end
    end

    context "when searching for word capitalized in original text" do
      xit 'returns matches to suggest search when case does not match with case maintained' do
        get solr_document_iiif_suggest_path(yale_work[:id], { q: 'pa' })
        expect(response).to have_http_status(:success)
        term_matches = JSON.parse(response.body)["terms"].map { |term| term["match"] }
        expect(term_matches).to include "Pakistan"
        expect(term_matches).to include "Paris"
      end

      xit 'returns matches to suggest search case does match with case maintained' do
        get solr_document_iiif_suggest_path(yale_work[:id], { q: 'Pa' })
        expect(response).to have_http_status(:success)
        term_matches = JSON.parse(response.body)["terms"].map { |term| term["match"] }
        expect(term_matches).to include "Pakistan"
        expect(term_matches).to include "Paris"
      end
    end
  end
end
