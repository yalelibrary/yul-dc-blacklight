# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'search result', type: :system, clean: true do
  let(:thumbnail_size) { "!200,200" }

  before do
    solr = Blacklight.default_index.connection
    solr.add(document_with_image)
    solr.commit
    stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
      .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
  end

  let(:document_with_image) do
    {
      id: 'test_record_1',
      oid_ssi: '2055095',
      visibility_ssi: 'Public',
      callNumber_tesim: 'Call Number',
      thumbnail_path_ss: "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg"
    }
  end

  context 'in list view' do
    before do
      visit '/catalog?search_field=all_fields&view=list'
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
      expect(page).to have_selector '#documents > .document-position-1 span', visible: true
    end

    it 'has a no index meta tag in header' do
      expect(page).to have_css("meta[name=robots][content=noindex]", visible: false)
    end
  end

  context 'in gallery view' do
    before do
      visit '/catalog?q=&search_field=all_fields&view=gallery'
    end

    it 'has expected css' do
      expect(page).to have_css '.caption'
    end

    it 'has the correct "per page" options' do
      expect(page).to have_text '9 per page 30 per page 60 per page 99 per page'
    end

    it 'does not show the index number' do
      expect(page).not_to have_selector('.document-counter span', visible: true)
    end

    it 'has a no index meta tag in header' do
      expect(page).to have_css("meta[name=robots][content=noindex]", visible: false)
    end
  end

  context 'in gallery view by session' do
    before do
      visit '/catalog?q=&search_field=all_fields&view=gallery'
      visit '/catalog?q=&search_field=all_fields'
    end

    it 'has expected css' do
      expect(page).to have_css '.caption'
    end

    it 'has the correct "per page" options' do
      expect(page).to have_text '9 per page 30 per page 60 per page 99 per page'
    end

    it 'does not show the index number' do
      expect(page).not_to have_selector('.document-counter span', visible: true)
    end
  end

  context 'in list view after gallery view set in session' do
    before do
      visit '/catalog?q=&search_field=all_fields&view=gallery'
      visit '/catalog?search_field=all_fields&view=list'
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
      expect(page).to have_selector '#documents > .document-position-1 span', visible: true
    end
  end

  context 'on catalog page without results' do
    before do
      visit '/catalog'
    end

    it 'does not have a no index meta tag in header' do
      expect(page).not_to have_css("meta[name=robots][content=noindex]", visible: false)
    end
  end

  context 'Caption search functionality' do
    let(:document_with_new_format_captions) do
      {
        id: 'caption_test_1',
        oid_ssi: '1001',
        title_tesim: ['Historic Missouri Collection'],
        visibility_ssi: 'Public',
        caption_tesim: ['112: Sketch of the Missouri River showing steamboats', '113: Portrait of frontier settlers', '114: Map of the western territory'],
        child_oids_ssim: [112, 113, 114],
        resourceType_ssim: 'Photographs',
        callNumber_tesim: 'MS 001'
      }
    end

    let(:document_with_multiple_matching_captions) do
      {
        id: 'caption_test_3',
        oid_ssi: '1003',
        title_tesim: ['Lincoln Collection'],
        visibility_ssi: 'Public',
        caption_tesim: ['201: Abraham Lincoln portrait', '202: Lincoln at Gettysburg', '203: Lincoln Memorial photograph', '204: Historical map'],
        child_oids_ssim: [201, 202, 203, 204],
        resourceType_ssim: 'Photographs',
        callNumber_tesim: 'MS 003'
      }
    end

    let(:document_without_matching_captions) do
      {
        id: 'caption_test_4',
        oid_ssi: '1004',
        title_tesim: ['Document Without Matching Captions'],
        visibility_ssi: 'Public',
        caption_tesim: ['301: Unrelated content here'],
        child_oids_ssim: [301],
        resourceType_ssim: 'Photographs',
        callNumber_tesim: 'MS 004'
      }
    end

    before do
      manifest_fixture = File.open(File.join('spec', 'fixtures', '2041002.json')).read
      stub_request(:get, "https://yul-dc-development-samples.s3.amazonaws.com/manifests/10/01/caption_test_1.json")
        .to_return(status: 200, body: manifest_fixture, headers: {})
      stub_request(:get, "https://yul-dc-development-samples.s3.amazonaws.com/manifests/10/03/caption_test_3.json")
        .to_return(status: 200, body: manifest_fixture, headers: {})
      stub_request(:get, "https://yul-dc-development-samples.s3.amazonaws.com/manifests/10/04/caption_test_4.json")
        .to_return(status: 200, body: manifest_fixture, headers: {})

      solr = Blacklight.default_index.connection
      solr.add(document_with_new_format_captions)
      solr.add(document_with_multiple_matching_captions)
      solr.add(document_without_matching_captions)
      solr.commit
    end

    context 'when searching for caption text' do
      it 'displays caption field for documents with matching new format captions' do
        visit '/catalog?q=Missouri&search_field=all_fields'
        within '#documents' do
          expect(page).to have_css('.blacklight-caption_tesim')
          expect(page).to have_text('Sketch of the Missouri River')
        end
      end

      it 'shows caption link with child_oid parameter' do
        visit '/catalog?q=Missouri&search_field=all_fields'
        within '#documents' do
          expect(page).to have_link(href: /child_oid=112/)
          expect(page).to have_link(href: /show_captions=true/)
        end
      end

      it 'does not display caption field when captions do not match search query' do
        visit '/catalog?q=unmatched&search_field=all_fields'
        expect(page).not_to have_css('.blacklight-caption_tesim')
      end

      it 'does not search child_oid numbers' do
        visit '/catalog?q=112&search_field=all_fields'
        within '#documents' do
          expect(page).not_to have_css('.blacklight-caption_tesim')
          expect(page).not_to have_text('Sketch of the Missouri')
        end
      end

      it 'strips child_oid prefix from displayed caption text' do
        visit '/catalog?q=frontier&search_field=all_fields'
        within '#documents' do
          expect(page).to have_text('Portrait of frontier settlers')
          expect(page).not_to have_text('113: Portrait')
        end
      end
    end

    context 'with multiple matching captions' do
      it 'displays the first matching caption' do
        visit '/catalog?q=Lincoln&search_field=all_fields'
        within "[data-document-id='caption_test_3']" do
          expect(page).to have_css('.blacklight-caption_tesim')
          expect(page).to have_text('Abraham Lincoln portrait')
        end
      end

      it 'shows note about additional caption matches' do
        visit '/catalog?q=Lincoln&search_field=all_fields'
        within "[data-document-id='caption_test_3']" do
          expect(page).to have_css('em', text: /More caption search results available on object page/i)
        end
      end

      it 'links to show page with show_captions parameter' do
        visit '/catalog?q=Lincoln&search_field=all_fields'
        within "[data-document-id='caption_test_3']" do
          expect(page).to have_link(href: /show_captions=true/)
          expect(page).to have_link(href: /q=Lincoln/)
        end
      end
    end

    context 'caption highlighting' do
      it 'highlights matching search terms in caption text' do
        visit '/catalog?q=Missouri&search_field=all_fields'
        within '#documents' do
          expect(page).to have_css('.search-highlight, .highlight', text: /Missouri/i)
        end
      end
    end

    context 'in list view' do
      it 'displays captions in list view results' do
        visit '/catalog?q=Missouri&search_field=all_fields&view=list'
        within '.documents-list' do
          expect(page).to have_css('.blacklight-caption_tesim')
          expect(page).to have_text('Missouri River')
        end
      end
    end

    context 'in gallery view' do
      it 'displays captions in gallery view results' do
        visit '/catalog?q=Missouri&search_field=all_fields&view=gallery'
        within '.documents-gallery' do
          expect(page).to have_css('.blacklight-caption_tesim')
        end
      end
    end

    context 'caption link interaction' do
      it 'navigates to object show page when clicking caption link', js: true do
        visit '/catalog?q=Missouri&search_field=all_fields'
        within '#documents' do
          first('.blacklight-caption_tesim a').click
        end
        expect(page).to have_current_path(/catalog\/caption_test_1/)
        expect(page).to have_current_path(/show_captions=true/)
        expect(page).to have_current_path(/child_oid=112/)
      end
    end
  end
end
