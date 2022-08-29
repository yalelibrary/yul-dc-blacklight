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
      expect(page).to have_content('Full Text')
      expect(page).to have_content('OID [Parent/primary]')
      expect(page).to have_content('OID [Child/images]')
      expect(page).to have_content('Search full text that occurs in a work. Not all works contain searchable full text.')
      expect(page).to have_selector('input#all_fields_advanced[placeholder="Search words about the items"]')
      expect(page).to have_selector('input#fulltext_tsim_advanced[placeholder="Search words within the items"]')
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

    it 'all fields search does not look in full text field' do
      fill_in 'all_fields_advanced', with: 'fulltext'
      click_on 'SEARCH'

      within '#documents' do
        expect(page).not_to have_content('Record 1')
        expect(page).not_to have_content('Record 2')
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

    it 'gets correct search results from callNumber_tesim' do
      fill_in 'callNumber_tesim', with: '["Landberg MSS 596"]'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from date_fields with dateStructured_ssim' do
      fill_in 'date_fields', with: '1459'
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

    it 'gets correct search results from full text field for both documents' do
      fill_in 'fulltext_tsim_advanced', with: 'fulltext'
      click_on 'SEARCH'

      within '#documents' do
        expect(page).to have_content('Record 1')
        expect(page).to have_content('Record 2')
      end
    end

    it 'gets correct search results from full text field for one documents' do
      fill_in 'fulltext_tsim_advanced', with: 'four'
      click_on 'SEARCH'

      within '#documents' do
        expect(page).not_to have_content('Record 1')
        expect(page).to have_content('Record 2')
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

    it 'gets correct search results from child oid_ssi' do
      fill_in 'child_oids_ssim', with: '11'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'gets correct search results from digitization_note_tesi' do
      fill_in 'digitization_note_tesi', with: 'microfilm'
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

    it 'maintains search results after changing sort dropdown' do
      fill_in 'oid_ssi', with: '11607445'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
      within '#sort-dropdown' do
        click_on 'Year (ascending)'
      end
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'maintains search results after clicking per page' do
      fill_in 'oid_ssi', with: '11607445'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
      within '#per_page-dropdown' do
        click_on '50'
      end
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
    end

    it 'clears search results when re-querying' do
      fill_in 'oid_ssi', with: '11607445'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to     have_content('Record 1')
        expect(page).not_to have_content('Record 2')
      end
      click_on 'Advanced Search'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content('Record 1')
        expect(page).to have_content('Record 2')
      end
    end
  end

  describe 'sanitizing quotes' do
    context 'when quotes are consecutive' do
      it 'removes one quote' do
        fill_in 'all_fields_advanced', with: '""nested""'
        click_on 'SEARCH'

        searched_text = find 'span .filter-value'
        expect(searched_text).to have_content '"nested"'
      end
    end
    context 'when a quote is not closed' do
      it 'removes all quotes' do
        fill_in 'all_fields_advanced', with: '"not" "closed'
        click_on 'SEARCH'

        searched_text = find 'span .filter-value'
        expect(searched_text).to have_content 'not closed'
      end
    end
  end

  context 'sorting' do
    it 'can sort by title' do
      within '#sort' do
        find("option[value='title_ssim asc, oid_ssi desc, archivalSort_ssi asc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end

    it 'can sort by creator' do
      within '#sort' do
        find("option[value='creator_ssim asc, title_ssim asc, archivalSort_ssi asc']").click
      end

      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end

    it 'can sort by date asc' do
      within '#sort' do
        find("option[value='year_isim asc, id desc, archivalSort_ssi asc']").click
      end
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content("1.\nRecord 1")
        expect(page).to have_content("2.\nRecord 2")
      end
    end

    it 'can sort by date desc' do
      within '#sort' do
        find("option[value='year_isim desc, id desc, archivalSort_ssi asc']").click
      end
      click_on 'SEARCH'
      # same order as asc because Record 1's dates strattle Record 2's
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

    it 'combines results with complex "OR" query' do
      fill_in 'all_fields_advanced', with: '(zeno OR me)'
      click_on 'SEARCH'
      within '#documents' do
        expect(page).to have_content('Record 1')
        expect(page).to have_content('Record 2')
      end
    end
  end

  describe 'styling' do
    it 'renders field input style' do
      expect(page).to have_css '.advanced_search_fields'
      expect(page).to have_css '.advanced-search-field', count: 10
    end

    it 'renders help section style' do
      expect(page).to have_css '.adv-search-help'
    end

    it 'renders footer buttons' do
      expect(page).to have_button 'SEARCH'
      expect(page).to have_button 'CLEAR'
      expect(page).to have_button 'BASIC SEARCH'
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
      expect(page).to have_button('Advanced Search')
      find('.advanced_search').hover
    end
  end
end
