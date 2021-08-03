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
      creator_tesim: 'Me and You',
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
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
  end
end
