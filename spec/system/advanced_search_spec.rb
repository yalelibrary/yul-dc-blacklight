# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search the catalog using advanced search', type: :system, js: true, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat])
    solr.commit
    visit search_catalog_path
    click_on "Advanced Search"
  end

  let(:dog) { ADVANCED_SEARCH_TESTING_1 }

  let(:cat) { ADVANCED_SEARCH_TESTING_2 }

  describe 'search fields' do
    it 'has the correct text field labels' do
      expect(page).to have_content('All Fields')
      expect(page).to have_content('Creator')
      expect(page).to have_content('Title')
      expect(page).to have_content('Call Number')
      expect(page).to have_content('Date')
      expect(page).to have_content('Subject')
      expect(page).to have_content('Genre/format')
      expect(page).to have_content('OID [Parent/primary]')
      expect(page).to have_content('OID [Child/images]')
    end
  end

  describe 'searching' do
    it 'gets correct search results from advanced fields' do
      fill_in 'all_fields_advanced', with: 'Latin'
      click_on 'SEARCH'

      within '#documents' do
        expect(page).not_to have_content('Record 1')
        expect(page).to have_content('Record 2')
      end
    end

    it 'gets correct search results from creator_tesim' do
      fill_in 'creator_tesim', with: 'Me and Frederick'
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

    it 'maintains search results in gallery' do
      fill_in 'oid_ssi', with: '11607445'
      click_on 'SEARCH'
      click_on 'Gallery'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
      click_on 'List'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'maintains search results when re-querying' do
      fill_in 'oid_ssi', with: '11607445'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
      click_on 'Advanced Search'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end
  end

  context 'sorting' do
    xit 'can sort by date from oldest to newest' do
      within '#sort' do
        find("option[value='dateStructured_ssim desc, title_si asc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end

    xit 'can sort by date from newest to oldest' do
      within '#sort' do
        find("option[value='dateStructured_ssim asc, title_si asc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 2")
        expect(page).to have_content("2.\nRecord 1")
      end
    end

    xit 'can sort by year' do
      within '#sort' do
        find("option[value='pub_date_si desc, title_si asc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end

    it 'can sort by title' do
      within '#sort' do
        find("option[value='title_ssim asc, oid_ssi desc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end

    it 'can sort by creator' do
      within '#sort' do
        find("option[value='creator_ssim asc, title_ssim asc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end
  end

  context 'Boolean logic' do
    it 'displays both records with "any"' do
      within '#op' do
        find("option[value='OR']").click
      end

      fill_in 'oid_ssi', with: '11607445' # for record 1
      fill_in 'creator_tesim', with: 'Zeno, Jacopo, 1417-1481' # for record 2
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content('Record 1')
        expect(page).to have_content('Record 2')
      end
    end

    it 'displays only 1 record with "all"' do
      within '#op' do
        find("option[value='AND']").click
      end

      fill_in 'oid_ssi', with: '11607445' # for record 1
      fill_in 'creator_tesim', with: '*'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end
  end

  describe 'styling' do
    it 'renders field input style' do
      expect(page).to have_css '.advanced_search_fields'
      expect(page).to have_css '.advanced-search-field', count: 9
    end

    it 'renders help section style' do
      expect(page).to have_css '.adv-search-help'
    end

    it 'renders footer buttons' do
      expect(page).to have_button 'SEARCH'
      expect(page).to have_link 'CLEAR', href: "/advanced"
      expect(page).to have_link 'BASIC SEARCH', href: "/"
    end

    it 'renders header border' do
      expect(page).to have_css '.adv-search-border-top'
    end

    it 'renders footer border' do
      expect(page).to have_css '.adv-search-border-bottom'
    end

    it 'render sort and submit buttons in header' do
      expect(page).to have_css '.sort-buttons'
      expect(page).to have_css '#op'
    end

    it 'does not render default find items that match in header' do
      expect(page).to have_css '.query_criteria_heading'
    end

    it 'renders the button on the homepage' do
      visit search_catalog_path
      expect(page).to have_css '.advanced_search'
      expect(page).to have_link('Advanced Search', href: '/advanced')
      find('.advanced_search').hover
    end
  end
end
