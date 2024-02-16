# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Show Page', type: :system, js: true, clean: true do
  let(:thumbnail_size_in_opengraph) { "!1200,630" }
  let(:thumbnail_size_in_solr) { "!200,200" }

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
    visit '/catalog?search_field=all_fields&q='
    click_on 'Amor Llama', match: :first
  end

  around do |example|
    original_blacklight_url = ENV['BLACKLIGHT_HOST']
    ENV['BLACKLIGHT_HOST'] = 'http://www.example.com/'
    example.run
    ENV['BLACKLIGHT_HOST'] = original_blacklight_url
  end

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

  it 'has expected css' do
    expect(page).to have_css '.btn-show'
    expect(page).to have_css '.constraints-container'
    expect(page).to have_css '.show-buttons'
    expect(page).to have_css '.manifestItem'
  end

  context '"Back to Search Results" button' do
    it 'returns user to search results' do
      expect(page).to have_button("Back to Search Results")
      expect(page).to have_xpath("//button[@href='/catalog?page=1&per_page=10&search_field=all_fields']")
    end
  end

  context 'Archival Context breadcrumbs' do
    it 'renders the Archival Context' do
      expect(page).to have_content 'Found In:'
      expect(page).to have_content 'Beinecke Rare Book and Manuscript Library (BRBL) > Abraham Lincoln collection (GEN MSS 257) > Series 1: Oversize > ... >'
      click_on("...")
      expect(page).to have_content 'Beinecke Rare Book and Manuscript Library (BRBL) > Abraham Lincoln collection (GEN MSS 257) > Series 1: Oversize > Level3 > Level2 > Level1 > Level0'
    end
  end

  context '"New Search" button' do
    it 'returns user to homepage' do
      expect(page).to have_button "New Search"
      expect(page).to have_xpath("//button[@href='/catalog']")
      expect(page.first('button.catalog_startOverLink').text).to eq 'New Search'
    end
  end

  context 'Universal Viewer' do
    it 'does not have a .json extension in the src attribute' do
      src = find('.universal-viewer-iframe')['src']
      expect(src).not_to include('.json')
    end

    context 'sending child oid as a parameter' do
      it 'uses child\'s page when oid is valid' do
        visit 'catalog/111?image_id=113'
        src = find('.universal-viewer-iframe')['src']
        expect(src).to eq("#{ENV['BLACKLIGHT_HOST']}/uv/uv.html#?manifest=#{ENV['BLACKLIGHT_HOST']}/manifests/111&cv=0").or eq("#{ENV['BLACKLIGHT_HOST']}/uv/uv.html#?manifest=#{ENV['BLACKLIGHT_HOST']}/manifests/111&cv=1")
      end
      it 'uses first page when oid is invalid' do
        visit 'catalog/111?image_id=11312321'
        src = find('.universal-viewer-iframe')['src']
        expect(src).to include '&cv=0'
      end
    end

    context 'without full text available' do
      it 'does not have a full text button' do
        visit 'catalog/222'

        expect(page).not_to have_css('.fulltext-button')
      end
    end

    context 'with full text available' do
      it 'has a "Show Full Text" button' do
        visit 'catalog/111'

        expect(page).to have_css('.fulltext-button')
        expect(page).to have_content('Show Full Text')
      end
      it 'has a "Show Full Text" button with a partial fulltext status' do
        visit 'catalog/112'

        expect(page).to have_css('.fulltext-button')
        expect(page).to have_content('Show Full Text')
      end
    end
  end

  context 'with public works' do
    it 'Metadata og tags are in the header of html' do
      expect(page).to have_css("meta[property='og:title'][content='Amor Llama']", visible: false)
      expect(page).to have_css("meta[property='og:url'][content='https://collections.library.yale.edu/catalog/111']", visible: false)
      expect(page).to have_css("meta[property='og:type'][content='website']", visible: false)
      expect(page).to have_css("meta[property='og:description'][content='Anna Elizabeth Dewdney']", visible: false)
      expect(page).to have_css("meta[property='og:image'][content='https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_opengraph}/0/default.jpg']", visible: false)
      expect(page).to have_css("meta[property='og:image:type'][content='image/jpeg']", visible: false)
    end
    it 'has og namespace' do
      expect(page).to have_css("html[prefix='og: https://ogp.me/ns#']", visible: false)
    end
  end

  context 'with yale-only works' do
    before do
      visit 'catalog/555'
    end
    it 'does not have image of og tag' do
      expect(page).not_to have_css("meta[property='og:image'][content='https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_opengraph}/0/default.jpg']", visible: false)
      expect(page).not_to have_css("meta[property='og:image:type'][content='image/jpeg']", visible: false)
    end
  end

  context "Metadata block" do
    it 'is not displayed when empty', :use_other_vis do
      visit 'catalog/666'

      expect(page).not_to have_content "Description", count: 2
      expect(page).not_to have_content "Collection Information"
      expect(page).not_to have_content "Subjects, Formats, And Genres"
      expect(page).not_to have_content "Access And Usage Rights"
      expect(page).not_to have_content "Identifiers"
    end
    it 'is displayed when they have values' do
      expect(page).to have_content "Description", count: 2
      expect(page).to have_content "Collection Information"
      expect(page).to have_content "Subjects, Formats, And Genres"
      expect(page).to have_content "Access And Usage Rights"
      expect(page).to have_content "Identifiers"
    end
  end
end
