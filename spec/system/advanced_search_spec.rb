# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search the catalog using advanced search', type: :system, js: true, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat])
    solr.commit
    visit root_path
    click_on "Advanced Search"
  end

  let(:dog) { ADVANCED_SEARCH_TESTING_1 }

  let(:cat) { ADVANCED_SEARCH_TESTING_2 }

  describe 'searching' do
    it 'gets correct search results from advanced fields' do
      fill_in 'all_fields_advanced', with: 'Latin'
      click_on 'SEARCH'

      within '#documents' do
        expect(page).not_to have_content('Record 1')
        expect(page).to have_content('Record 2')
      end
    end

    it 'gets correct search results from author_tesim' do
      fill_in 'author_tesim', with: 'Me and Frederick'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from identifierShelfMark_tesim' do
      fill_in 'identifierShelfMark_tesim', with: '["Landberg MSS 596"]'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from date_fields with date_ssim' do
      fill_in 'date_fields', with: '[17--?]'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from date_fields with dateStructured_ssim' do
      fill_in 'date_fields', with: '1700-00-00T00:00:00Z'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from subject_fields' do
      fill_in 'subject_fields', with: 'Belles lettres'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from genre_fields' do
      fill_in 'genre_fields', with: 'Manuscripts'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).not_to have_content('Record 1')
        expect(page).to     have_content('Record 2')
      end
    end

    it 'gets correct search results from title_tesim' do
      fill_in 'title_tesim', with: '["Record 1"]'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from oid_ssi' do
      fill_in 'oid_ssi', with: '11607445'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from child oid_ssim' do
      fill_in 'child_oids_ssim', with: '11'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end
  end

  describe 'styling' do
    it 'renders field input style' do
      expect(page).to have_css '.adv-search-fields'
    end

    it 'renders help section style' do
      expect(page).to have_css '.adv-search-help'
    end

    it 'renders footer buttons' do
      expect(page).to have_button 'SEARCH'
      expect(page).to have_link 'CLEAR', href: "/advanced"
      expect(page).to have_link 'BASIC SEARCH', href: "/"
    end

    it 'does not render default sort and submit buttons in footer' do
      expect(page).not_to have_css 'sort-submit-buttons'
    end

    it 'renders the button on the homepage' do
      visit root_path
      expect(page).to have_content "Advanced Search"
      expect(page).to have_css '.advanced_search'
      expect(page).to have_link('Advanced Search', href: '/advanced')
      find('.advanced_search').hover
    end
  end
end
