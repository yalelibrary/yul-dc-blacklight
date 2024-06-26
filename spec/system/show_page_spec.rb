# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Show Page', type: :system, js: true, clean: true do
  let(:thumbnail_size_in_opengraph) { "!1200,630" }
  let(:thumbnail_size_in_solr) { "!200,200" }

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      ancestorTitles_tesim: ['Level0', 'Level1', 'Level2', 'Level3', 'Oversize', 'Abraham Lincoln collection (GEN MSS 257)', 'Beinecke Rare Book and Manuscript Library (BRBL)'],
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney'],
      creator_tesim: ['Anna Elizabeth Dewdney'],
      child_oids_ssim: [112, 113],
      oid_ssi: 111,
      thumbnail_path_ss: "https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_solr}/0/default.jpg",
      callNumber_ssim: "call number",
      has_fulltext_ssi: 'Yes',
      series_ssi: "Series 1: Oversize"
    }
  end

  let(:llama_child_1) do
    {
      id: '112',
      title_tesim: ['Baby Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney'],
      fulltext_tesim: ['fulltext text for llama child one.'],
      has_fulltext_ssi: 'Partial'
    }
  end

  let(:llama_child_2) do
    {
      id: '113',
      title_tesim: ['Baby Llama 2: The Sequel'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney']
    }
  end

  let(:dog) do
    {
      id: '222',
      title_tesim: ['HandsomeDan Bulldog'],
      format: 'three dimensional object',
      language_ssim: 'en',
      visibility_ssi: 'Public',
      genre_ssim: 'Artifacts',
      resourceType_ssim: 'Books, Journals & Pamphlets',
      has_fulltext_ssi: 'No',
      creator_ssim: ['Andy Graves']
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_tesim: ['Aquila Eccellenza'],
      format: 'still image',
      language_ssim: 'it',
      visibility_ssi: 'Public',
      genre_ssim: 'Manuscripts',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['Andrew Norriss']
    }
  end

  let(:puppy) do
    {
      id: '444',
      title_tesim: ['Rhett Lecheire'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Public',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['Paulo Coelho']
    }
  end

  let(:train) do
    {
      id: '555',
      title_tesim: ['The Boiler Makers'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Yale Community Only',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['France A. Cordova'],
      oid_ssi: 555,
      thumbnail_path_ss: "https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_solr}/0/default.jpg"
    }
  end

  let(:void) do
    {
      other_vis_bsi: true,
      id: '666'
    }
  end

  before do
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/111.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/112.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/113.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/22/22/222.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/12/11/112.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)

    solr = Blacklight.default_index.connection
    solr.add([llama,
              llama_child_1,
              llama_child_2,
              dog,
              eagle,
              puppy,
              train,
              void])
    solr.commit
  end

  context 'public work' do
    before do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
    end
    it 'has expected css' do
      expect(page).to have_css '.btn-show'
      expect(page).to have_css '.constraints-container'
      expect(page).to have_css '.show-buttons'
      expect(page).to have_css '.manifestItem'
    end
    it '"Back to Search Results" button returns user to search results' do
      expect(page).to have_button("Back to Search Results")
      expect(page).to have_xpath("//button[@href='/catalog?page=1&per_page=10&search_field=all_fields']")
    end
    it 'Archival Context breadcrumbs render the Archival Context' do
      expect(page).to have_content 'Found In:'
      expect(page).to have_content 'Beinecke Rare Book and Manuscript Library (BRBL) > Abraham Lincoln collection (GEN MSS 257) > Series 1: Oversize > ... >'
      click_on("...")
      expect(page).to have_content 'Beinecke Rare Book and Manuscript Library (BRBL) > Abraham Lincoln collection (GEN MSS 257) > Series 1: Oversize > Level3 > Level2 > Level1 > Level0'
    end
    it '"New Search" button returns user to homepage' do
      expect(page).to have_button "New Search"
      expect(page).to have_xpath("//button[@href='/catalog']")
      expect(page.first('button.catalog_startOverLink').text).to eq('NEW SEARCH').or eq('New Search')
    end
    it 'with full text available has a "Show Full Text" button' do
      expect(page).to have_css('.fulltext-button')
      expect(page).to have_content('Show Full Text')
    end
    # flappy
    xit 'Metadata og tags are in the header of html' do
      expect(page.html).to include("og:title")
      expect(page.html).to include("Amor Llama")
      expect(page.html).to include("og:url")
      expect(page.html).to include("https://collections.library.yale.edu/catalog/111")
      expect(page.html).to include("og:type")
      expect(page.html).to include("website")
      expect(page.html).to include("og:description")
      expect(page.html).to include("Anna Elizabeth Dewdney")
      expect(page.html).to include("og:image")
      expect(page.html).to include("https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_opengraph}/0/default.jpg")
      expect(page.html).to include("og:image:type")
      expect(page.html).to include("image/jpeg")
    end
    it 'has og namespace' do
      expect(page).to have_css("html[prefix='og: https://ogp.me/ns#']", visible: false)
    end
    it 'metadata block is displayed when it has values' do
      expect(page).to have_content "Description", count: 2
      expect(page).to have_content "Collection Information"
      expect(page).to have_content "Subjects, Formats, And Genres"
      expect(page).to have_content "Access And Usage Rights"
      expect(page).to have_content "Identifiers"
    end

    context 'Universal Viewer' do
      it 'does not have a .json extension in the src attribute' do
        src = find('.universal-viewer-iframe')['src']
        expect(src).not_to include('.json')
      end

      context 'sending child oid as a parameter' do
        # TODO: re-enable test when result is consistent
        xit 'uses child\'s page when oid is valid' do
          visit 'catalog/111?image_id=113'
          src = find('.universal-viewer-iframe')['src']
          expect(src).to include '&cv=1'
        end
        it 'uses first page when oid is invalid' do
          visit 'catalog/111?image_id=11312321'
          src = find('.universal-viewer-iframe')['src']
          expect(src).to include '&cv=0'
        end
      end
    end
  end

  context 'with yale-only works' do
    it 'does not have image of og tag' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'The Boiler Makers', match: :first
      expect(page).not_to have_css("meta[property='og:image'][content='https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_opengraph}/0/default.jpg']")
      expect(page).not_to have_css("meta[property='og:image:type'][content='image/jpeg']")
    end
  end

  context "Metadata block" do
    it 'is not displayed when it has no values', :use_other_vis do
      visit 'catalog/666'

      expect(page).not_to have_content "Description", count: 2
      expect(page).not_to have_content "Collection Information"
      expect(page).not_to have_content "Subjects, Formats, And Genres"
      expect(page).not_to have_content "Access And Usage Rights"
      expect(page).not_to have_content "Identifiers"
    end
  end

  context 'Full text button' do
    # flappy
    xit 'does not have a full text button without full text available' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'HandsomeDan Bulldog', match: :first

      expect(page).to have_content('HandsomeDan Bulldog')
      expect(page).not_to have_content('Show Full Text')
    end
    it 'has a "Show Full Text" button with a partial fulltext status' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Baby Llama', match: :first

      expect(page).to have_css('.fulltext-button')
      expect(page).to have_content('Show Full Text')
    end
  end
end
