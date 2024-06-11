# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Saved Items', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog])
    solr.commit
  end

  let(:user) { FactoryBot.create(:user) }

  let(:dog) do
    {
      id: '111',
      creator_ssim: 'Me and You',
      title_tesim: ['Amor Perro'],
      date_ssim: '1999',
      repository_ssi: 'Beinecke Rare Book and Manuscript Library (BRBL)',
      collection_name_ssi: 'Osborn Manuscript Files (OSB MSS FILE)',
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

  context 'With a logged out user' do
    it 'does not display save item option in search results' do
      visit '/catalog?search_field=all_fields&q='
      expect(page).not_to have_content('Save Item')
    end
  end

  context 'With a logged in user' do
    before do
      login_as user
    end
    it 'displays save item option in search results' do
      visit '/catalog?search_field=all_fields&q='
      expect(page).to have_content('Save Item')
    end
  end


end
