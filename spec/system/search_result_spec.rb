# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'search result', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add(document_with_image)
    solr.commit
    stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg")
      .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
  end

  let(:document_with_image) do
    {
      id: 'test_record_1',
      oid_ssi: '2055095',
      visibility_ssi: 'Public',
      identifierShelfMark_tesim: 'Call Number',
      thumbnail_path_ss: "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg"
    }
  end

  context 'in list view' do
    before do
      visit '/?search_field=all_fields&view=list'
    end
    it 'has expected css', js: true, style: true do
      within '.documents-list' do
        expect(page).to have_css '.dl-invert'
        expect(page).to have_css '.document-metadata'
        expect(page).to have_css '.document-title'
        expect(page).to have_css '.document-title-heading'
        expect(page).to have_css '.documentHeader'
        expect(page).to have_css '.row'
        expect(page).to have_css '.document'
        expect(page).to have_css '.document-metadata.dl-invert.row'
        expect(page).to have_css '#documents > article.document > dl > dt'
        expect(page).to have_css '.document-metadata.dl-invert > dt'
        expect(page).to have_css '.document-metadata.dl-invert > dd'
        expect(page).to have_css '.document-metadata'
        expect(page).to have_css '.document-thumbnail'
        expect(page).to have_css '.col-md-9'
      end
    end

    it 'has the correct "per page" options' do
      expect(page).to have_text '10 per page 20 per page 50 per page 100 per page'
    end

    it 'shows the index number' do
      expect(page).to have_selector '#documents > .document-position-0 span', visible: true
    end
  end

  context 'in gallery view' do
    before do
      visit '/?q=&search_field=all_fields&view=gallery'
    end

    it 'has the correct "per page" options' do
      expect(page).to have_text '9 per page 30 per page 60 per page 99 per page'
    end

    it 'does not show the index number' do
      expect(page).not_to have_selector '#documents > .document.col:first-child span'
    end
  end
end
