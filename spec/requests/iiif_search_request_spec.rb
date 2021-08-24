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

  before do
    solr = Blacklight.default_index.connection
    solr.add([yale_work, child_work1, child_work2])
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
