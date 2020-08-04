# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results displays field', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog])
    solr.commit
    visit '/?search_field=all_fields&q='
  end

  let(:dog) do
    {
      id: '111',
      author_tsim: 'Me and You',
      author_vern_ssim: 'Me and You',
      date_ssim: '1999',
      resourceType_ssim: 'Archives or Manuscripts',
      partOf_ssim: 'Beinecke Library',
      identifierShelfMark_ssim: 'Beinecke MS 801',
      imageCount_isi: '23',
      visibility_ssi: 'Public'
    }
  end

  context 'Within search results' do
    subject(:content) { find(:css, '#main-container') }

    it 'displays Date in results' do
      expect(content).to have_content('1999')
    end
    it 'displays Author in results' do
      expect(content).to have_content('Me and You').twice
    end
    it 'displays Resource Type in results' do
      expect(content).to have_content('Archives or Manuscripts')
    end
    it 'displays Collection Name in results' do
      expect(content).to have_content('Beinecke Library')
    end
    it 'displays Call Number in results' do
      expect(content).to have_content('Beinecke MS 801')
    end
    it 'displays Image Count in results' do
      expect(content).to have_content('23')
    end
  end
end
