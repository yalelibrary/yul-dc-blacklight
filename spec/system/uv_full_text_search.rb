# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching for full text and navigate to the UV', type: :system, js: true, clean: true do
  before do
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/01/1.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)

    solr = Blacklight.default_index.connection
    solr.add([dog])
    solr.commit
  end

  let(:dog) { ADVANCED_SEARCH_TESTING_1 }

  it 'adds the fulltext search parameter to the iframe src URL in advanced search' do
    visit search_catalog_path
    click_on "Advanced Search"
    fill_in 'fulltext_tsim_advanced', with: 'fulltext'
    click_on 'SEARCH'
    click_on 'Record 1'
    uv_iframe = page.find('.universal-viewer-iframe')
    expect(uv_iframe[:src]).to include('q=fulltext')
  end

  it 'adds the fulltext search parameter to the iframe src URL in simple search' do
    visit search_catalog_path
    choose('fulltext_search_2')
    fill_in 'q', with: 'fulltext'
    within '.input-group-append' do
      click_button("Search")
    end
    click_on 'Record 1'
    uv_iframe = page.find('.universal-viewer-iframe')
    expect(uv_iframe[:src]).to include('q=fulltext')
  end
end
