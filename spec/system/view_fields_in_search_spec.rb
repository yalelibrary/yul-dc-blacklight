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
      visibility_ssi: 'Public'
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
  end
end
