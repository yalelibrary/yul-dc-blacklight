# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search the catalog using advanced search', type: :system, js: true, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat])
    solr.commit
  end

  let(:dog) { ADVANCED_SEARCH_TESTING_1 }

  let(:cat) { ADVANCED_SEARCH_TESTING_2 }

  it 'has css for the button' do
    visit root_path
    page.should have_content "Advanced Search"
    expect(page).to have_css '.advanced_search'
    expect(page).to have_link('Advanced Search', href: '/advanced')
    find('.advanced_search').hover
  end

  it 'gets correct search results from all fields' do
    visit root_path
    click_on "Advanced Search"
    # Search for something
    fill_in 'all_fields_advanced', with: 'Record 1'
    click_on 'advanced-search-submit'

    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
  it 'gets correct search results from author_tesim' do
    visit root_path
    click_on 'Advanced Search'
    # Search for something
    fill_in 'author_tesim', with: 'Me and Frederick'
    click_on 'advanced-search-submit'
    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
  it 'gets correct search results from identifierShelfMark_tesim' do
    visit root_path
    click_on 'Advanced Search'
    # Search for something
    fill_in 'identifierShelfMark_tesim', with: '["Landberg MSS 596"]'
    click_on 'advanced-search-submit'
    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
  it 'gets correct search results from orbisBibId_ssi' do
    visit root_path
    click_on 'Advanced Search'
    # Search for something
    fill_in 'orbisBibId_ssi', with: '3832098'
    click_on 'advanced-search-submit'
    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
  it 'gets correct search results from title_tesim' do
    visit root_path
    click_on 'Advanced Search'
    # Search for something
    fill_in 'title_tesim', with: '["Record 1"]'
    click_on 'advanced-search-submit'
    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
  it 'gets correct search results from oid_ssi' do
    visit root_path
    click_on 'Advanced Search'
    # Search for something
    fill_in 'oid_ssi', with: '11607445'
    click_on 'advanced-search-submit'
    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
  it 'gets correct search results from child oid_ssim' do
    visit root_path
    click_on 'Advanced Search'
    # Search for something
    fill_in 'child_oids_ssim', with: '11'
    click_on 'advanced-search-submit'
    within '#documents' do
      expect(page).to     have_content('Record 1')
      expect(page).not_to have_content('Record 2')
    end
  end
end
