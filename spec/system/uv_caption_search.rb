# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Searching for full text and navigate to the UV', type: :system, js: true, clean: true do
  before do
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/01/1.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2005512.json')).read)

    solr = Blacklight.default_index.connection
    solr.add([dog, puppy_one, puppy_two])
    solr.commit
  end

  let(:dog) { ADVANCED_SEARCH_TESTING_3 }
  let(:puppy_one) { ADVANCED_SEARCH_TESTING_3_CHILD_1 }
  let(:puppy_two) { ADVANCED_SEARCH_TESTING_3_CHILD_2 }

  it 'adds the oid for matching caption to search parameter for the iframe src URL in simple search' do
    visit search_catalog_path
    fill_in 'q', with: 'front view'
    within '.input-group-append' do
      click_button("Search")
    end
    byebug
    click_on '- front view'
    uv_iframe = page.find('.universal-viewer-iframe')
    expect(uv_iframe[:src]).to include('q=front+view')
    expect(page.url).to include('child_oid=1030368')
  end
end
