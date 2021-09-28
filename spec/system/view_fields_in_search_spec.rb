# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results displays field', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog])
    solr.commit
    visit '/catalog?search_field=all_fields&q='
  end

  let(:dog) do
    {
      id: '111',
      creator_ssim: 'Me and You',
      title_tesim: ['Amor Perro'],
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
      callNumber_tesim: 'Beinecke MS 801',
      containerGrouping_tesim: 'BRBL_091081',
      imageCount_isi: '23',
      visibility_ssi: 'Public',
      ancestorTitles_tesim: ['Beinecke Rare Book and Manuscript Library (BRBL)',
                             'Osborn Manuscript Files (OSB MSS FILE)',
                             'Numerical Sequence: 17975-19123',
                             'BURNEY, SARAH HARRIET, 1772-1844',
                             'Level3',
                             'Level2',
                             'Level1',
                             'Level0'],
      # rubocop:disable Layout/LineLength
      ancestor_titles_hierarchy_ssim: ["Beinecke Rare Book and Manuscript Library (BRBL) > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > Numerical Sequence: 17975-19123 > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > Numerical Sequence: 17975-19123 > BURNEY, SARAH HARRIET, 1772-1844 > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > Numerical Sequence: 17975-19123 > BURNEY, SARAH HARRIET, 1772-1844 > Level3 > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > Numerical Sequence: 17975-19123 > BURNEY, SARAH HARRIET, 1772-1844 > Level3 > Level2 > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > Numerical Sequence: 17975-19123 > BURNEY, SARAH HARRIET, 1772-1844 > Level3 > Level2 > Level1 > ",
                                       "Beinecke Rare Book and Manuscript Library (BRBL) > Osborn Manuscript Files (OSB MSS FILE) > Numerical Sequence: 17975-19123 > BURNEY, SARAH HARRIET, 1772-1844 > Level3 > Level2 > Level1 > Level0 > "]
      # rubocop:enable Layout/LineLength
    }
  end

  context 'Within search results' do
    subject(:content) { find(:css, '#main-container') }

    it 'displays Date in results' do
      expect(content).to have_content('1999')
    end
    it 'displays Creator in results' do
      expect(content).to have_content('Me and You')
    end
    it 'displays Resource Type in results' do
      expect(content).to have_content('Archives or Manuscripts')
    end
    it 'displays Call Number in results' do
      expect(content).to have_content('Beinecke MS 801')
    end
    it 'displays Container / Volume in results' do
      expect(content).to have_content('BRBL_091081')
    end
    it 'displays Image Count in results' do
      expect(content).to have_content('23')
    end
    it 'displays Ancestor Title (Found in) in results' do
      expect(content).to have_content('Osborn Manuscript Files (OSB MSS FILE)')
    end
    it 'displays Ancestor Title (Found in) in results with ellipsis' do
      expect(content).to have_content('Level0 > Level1 > Level2 > ...')
      expect(content).not_to have_content('Level0 > Level1 > Level2 > Level3')
      click_on("...")
      expect(content).not_to have_content('Level0 > Level1 > Level2 > Level3')
    end
    context 'Ancestor Title (Found in)' do
      it 'is displayed in results with links' do
        expect(content).to have_link("Level0")
        expect(content).to have_link("Amor Perro")
        click_on "Level0"
        expect(page).to have_content "Amor Perro"

        click_on "Beinecke Rare Book and Manuscript Library (BRBL)"
        expect(page).to have_content "Amor Perro"

        click_on("...")
        click_on "Level3"
        expect(page).to have_content "Amor Perro"

        # makes sure "found in" does not stack
        expect(page).to have_css ".filter-name", text: "Found In", count: 1
      end
      it 'does not keep other constraints when facet links are clicked' do
        click_on "Creator"
        click_on "Me and You"
        expect(page).to have_css ".filter-name", text: "Creator", count: 1

        click_on "Level0"

        expect(page).to have_css ".filter-name", text: "Found In", count: 1
        expect(page).to have_css ".filter-name", text: "Creator", count: 0
      end
    end
  end
end
