# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'archival sort', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog])
    solr.commit
    visit '/catalog?per_page=1&q=&search_field=all_fields'
  end

  let(:dog) do
    {
      id: '111',
      creator_tesim: 'Me and You',
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
      archivalSort_ssi: '00001.00038',
      callNumber_tesim: 'Beinecke MS 801',
      imageCount_isi: '23',
      visibility_ssi: 'Public',
      ancestorTitles_tesim: ['Beinecke Rare Book and Manuscript Library (BRBL)',
                             'Osborn Manuscript Files (OSB MSS FILE)',
                             'Numerical Sequence: 17975-19123',
                             'BURNEY, SARAH HARRIET, 1772-1844',
                             'Level3',
                             'Level2',
                             'Level1',
                             'Level0']
    }
  end

  let(:cat) do
    {
      id: '222',
      creator_tesim: 'Me and You',
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
      archivalSort_ssi: '00000.00040',
      callNumber_tesim: 'Beinecke MS 801',
      imageCount_isi: '23',
      visibility_ssi: 'Public',
      ancestorTitles_tesim: ['Beinecke Rare Book and Manuscript Library (BRBL)',
                             'Script Files',
                             'Numerical Sequence: 17975-19123',
                             'BURNEY, SARAH HARRIET, 1772-1844',
                             'Level3',
                             'Level2',
                             'Level1',
                             'Level0']
    }
  end

  context 'search results sorts based on archivalSort conditions' do
    it 'displays the first thing first' do
      expect(page).to have_content('Osborn Manuscript Files (OSB MSS FILE)')
    end
  end
end
