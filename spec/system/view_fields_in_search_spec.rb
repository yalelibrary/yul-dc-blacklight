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
      format: 'three dimensional object',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      lc_callnum_ssim: "123213213",
      language_ssim: ['en', 'eng', 'zz'],
      public_bsi: 1
    }
  end

  context 'Within search results' do
    subject(:content) { find(:css, '#content') }

    it 'displays language in results' do
      expect(content).to have_content("English (en)")
      expect(content).to have_content("English (eng)")
      expect(content).to have_content("zz")
    end
    it 'displays Author in results' do
      expect(content).to have_content("Me and You").twice
    end
    it 'displays Title in results' do
      expect(content).to have_content("HandsomeDan Bulldog", count: 3)
    end
    it 'displays Publishing in results' do
      expect(content).to have_content("1997").twice
    end
    it 'displays format in results' do
      expect(content).to have_content("three dimensional object")
    end
    it 'displays call number in results' do
      expect(content).to have_content("123213213")
    end
  end
end
