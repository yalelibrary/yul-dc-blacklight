# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'archivalSort', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog,
              cat,
              llama,
              eagle,
              puppy])
    solr.commit
    visit '/catalog?per_page=1&q=&search_field=all_fields'
  end

  let(:dog) do
    {
      id: '111',
      title_tesim: ['Amor Perro'],
      creator_tesim: 'Me and You',
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
      callNumber_tesim: 'Beinecke MS 801',
      imageCount_isi: '23',
      visibility_ssi: 'Public',
      archivalSort_ssi: '08001.00038',
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
      title_tesim: ['Amor Gato'],
      creator_tesim: 'Me and You',
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
      callNumber_tesim: 'Beinecke MS 801',
      imageCount_isi: '23',
      visibility_ssi: 'Public',
      archivalSort_ssi: '00006.00040',
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

  let(:llama) do
    {
      id: '333',
      title_tesim: ['Amor Llama'],
      creator_tesim: 'Anna Elizabeth Dewdney',
      date_ssim: '1999',
      repository_ssi: 'Yale University Arts Library',
      collection_title_ssi: ['AAA'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      archivalSort_ssi: '00000.00040',
      ancestorTitles_tesim: ['Beinecke Rare Book and Manuscript Library (BRBL)',
                             'Llama Files',
                             'Numerical Sequence: 17975-19123',
                             'BURNEY, SARAH HARRIET, 1772-1844',
                             'Level3',
                             'Level2',
                             'Level1',
                             'Level0']
    }
  end

  let(:eagle) do
    {
      id: '444',
      title_tesim: ['Aquila Eccellenza'],
      creator_tesim: 'Andrew Norriss',
      date_ssim: '1999',
      format: 'still image',
      language_ssim: 'it',
      visibility_ssi: 'Public',
      genre_ssim: 'Manuscripts',
      resourceType_ssim: 'Archives or Manuscripts',
      archivalSort_ssi: '00020.00040',
      ancestorTitles_tesim: ['Beinecke Rare Book and Manuscript Library (BRBL)',
                             'Eagle Files',
                             'Numerical Sequence: 17975-19123',
                             'BURNEY, SARAH HARRIET, 1772-1844',
                             'Level3',
                             'Level2',
                             'Level1',
                             'Level0']
    }
  end

  let(:puppy) do
    {
      id: '555',
      title_tesim: ['Rhett Lecheire'],
      creator_tesim: 'Paulo Coelho',
      date_ssim: '1999',
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Public',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      archivalSort_ssi: '04000.00040',
      ancestorTitles_tesim: ['Beinecke Rare Book and Manuscript Library (BRBL)',
                             'Puppy Files',
                             'Numerical Sequence: 17975-19123',
                             'BURNEY, SARAH HARRIET, 1772-1844',
                             'Level3',
                             'Level2',
                             'Level1',
                             'Level0']
    }
  end

  context 'search results' do
    it 'sorts based on archivalSort conditions' do
      expect(page).to have_content('Osborn Manuscript Files (OSB MSS FILE)')
      expect(page).not_to have_content('Script Files')
    end
  end
end
