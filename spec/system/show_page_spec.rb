# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Show Page', type: :system, js: true, clean: true do
  before do
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/111.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/112.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/113.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)

    solr = Blacklight.default_index.connection
    solr.add([llama,
              llama_child_1,
              llama_child_2,
              dog,
              eagle,
              puppy])
    solr.commit
    visit '/catalog?search_field=all_fields&q='
    click_on 'Amor Llama'
  end

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney'],
      creator_tesim: ['Anna Elizabeth Dewdney'],
      child_oids_ssim: [112, 113],
      oid_ssi: 111,
      thumbnail_path_ss: 'https://this/is/an/image'
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
      creator_ssim: ['Anna Elizabeth Dewdney']
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
      thumbnail_path_ss: 'https://this/is/an/image'
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
        visit 'catalog/111?child_oid=113'
        src = find('.universal-viewer-iframe')['src']
        expect(src).to include '&cv=1'
      end
      it 'uses first page when oid is invalid' do
        visit 'catalog/111?child_oid=11312321'
        src = find('.universal-viewer-iframe')['src']
        expect(src).to include '&cv=0'
      end
    end
  end

  context 'with public works' do
    it 'Metadata og tags are in the header of html' do
      expect(page).to have_css("meta[property='og:title'][content='Amor Llama']", visible: false)
      expect(page).to have_css("meta[property='og:url'][content='https://collections.library.yale.edu/catalog/111']", visible: false)
      expect(page).to have_css("meta[property='og:type'][content='website']", visible: false)
      expect(page).to have_css("meta[property='og:description'][content='Anna Elizabeth Dewdney']", visible: false)
      expect(page).to have_css("meta[property='og:image'][content='https://this/is/an/image']", visible: false)
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
      expect(page).not_to have_css("meta[property='og:image'][content='https://this/is/an/image']", visible: false)
      expect(page).not_to have_css("meta[property='og:image:type'][content='image/jpeg']", visible: false)
    end
  end
end
