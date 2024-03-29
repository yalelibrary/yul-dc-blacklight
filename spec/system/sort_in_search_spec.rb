# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results should be sorted', type: :system, js: :true, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([llama,
              dog,
              eagle,
              puppy])
    solr.commit
    visit search_catalog_path
  end

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      title_ssim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      archivalSort_ssi: '00000.00040',
      creationPlace_ssim: 'Spain',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_tesim: 'Anna Elizabeth Dewdney',
      creator_ssim: ['Anna Elizabeth Dewdney'],
      dateStructured_ssim: ['1911'],
      year_isim: [1690]
    }
  end

  let(:dog) do
    {
      id: '222',
      title_tesim: ['HandsomeDan Bulldog'],
      title_ssim: ['HandsomeDan Bulldog'],
      format: 'three dimensional object',
      language_ssim: 'en',
      visibility_ssi: 'Public',
      archivalSort_ssi: '08001.00038',
      creationPlace_ssim: 'New Haven',
      resourceType_ssim: 'Books, Journals & Pamphlets',
      creator_tesim: 'Andy Graves',
      creator_ssim: ['Andy Graves'],
      dateStructured_ssim: ['1755'],
      collection_title_ssi: "Test",
      year_isim: [1755]
    }
  end

  let(:puppy) do
    {
      id: '444',
      title_tesim: ['Rhett Lecheire'],
      title_ssim: ['Rhett Lecheire'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Public',
      archivalSort_ssi: '04000.00040',
      creationPlace_ssim: 'Constantinople or southern Italy',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_tesim: 'Paulo Coelho',
      creator_ssim: ['Paulo Coelho'],
      dateStructured_ssim: ['1972'],
      collection_title_ssi: "Test",
      year_isim: [1790]
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_tesim: ['Aquila Eccellenza'],
      title_ssim: ['Aquila Eccellenza'],
      format: 'still image',
      language_ssim: 'it',
      visibility_ssi: 'Public',
      archivalSort_ssi: '00020.00040',
      creationPlace_ssim: 'White-Hall, printed upon the ice, on the River Thames',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_tesim: 'Andrew Norriss',
      creator_ssim: ['Andrew Norriss'],
      dateStructured_ssim: ['1699'],
      year_isim: [1830]
    }
  end

  xit 'sorts by date from oldest to newest' do
    click_on 'search'
    click_on 'Sort by relevance'
    click_on 'date (oldest first)'

    content = find(:css, '#content')
    expect(content).to have_content("1.\nAquila Eccellenza")
    expect(content).to have_content("2.\nHandsomeDan Bulldog")
    expect(content).to have_content("3.\nAmor Llama")
    expect(content).to have_content("4.\nRhett Lecheire")
  end

  xit 'sorts by date from newest to oldest' do
    click_on 'search'
    click_on 'Sort by relevance'
    click_on 'date (newest first)'

    content = find(:css, '#content')
    expect(content).to have_content("1.\nRhett Lecheire")
    expect(content).to have_content("2.\nAmor Llama")
    expect(content).to have_content("3.\nHandsomeDan Bulldog")
    expect(content).to have_content("4.\nAquila Eccellenza")
  end

  context 'sorts by title' do
    it 'asc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Title (A --> Z)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("1.\nAmor Llama")
      expect(content).to have_content("2.\nAquila Eccellenza")
      expect(content).to have_content("3.\nHandsomeDan Bulldog")
      expect(content).to have_content("4.\nRhett Lecheire")
    end

    it 'desc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Title (Z --> A)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("4.\nAmor Llama")
      expect(content).to have_content("3.\nAquila Eccellenza")
      expect(content).to have_content("2.\nHandsomeDan Bulldog")
      expect(content).to have_content("1.\nRhett Lecheire")
    end
  end

  context 'sorts by creator' do
    it 'sorts by creator asc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Creator (A --> Z)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("1.\nAquila Eccellenza")
      expect(content).to have_content("2.\nHandsomeDan Bulldog")
      expect(content).to have_content("3.\nAmor Llama")
      expect(content).to have_content("4.\nRhett Lecheire")
    end

    it 'sorts by creator desc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Creator (Z --> A)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("4.\nAquila Eccellenza")
      expect(content).to have_content("3.\nHandsomeDan Bulldog")
      expect(content).to have_content("2.\nAmor Llama")
      expect(content).to have_content("1.\nRhett Lecheire")
    end
  end

  context 'sorts by year' do
    it 'sorts by year asc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Year (ascending)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("1.\nAmor Llama")
      expect(content).to have_content("2.\nHandsomeDan Bulldog")
      expect(content).to have_content("3.\nRhett Lecheire")
      expect(content).to have_content("4.\nAquila Eccellenza")
    end

    it 'sorts by year desc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Year (descending)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("1.\nAquila Eccellenza")
      expect(content).to have_content("2.\nRhett Lecheire")
      expect(content).to have_content("3.\nHandsomeDan Bulldog")
      expect(content).to have_content("4.\nAmor Llama")
    end
  end

  context 'sorts by collection with correct facets' do
    it 'does not have sort by collection by default' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        expect(page).not_to have_content("Collection Order")
      end
    end
  end

  context 'sorts by collection with correct facets' do
    it 'does not have sort by collection by default' do
      visit "/catalog?f[collection_title_ssi][]=Test"
      content = find(:css, '#content')
      expect(content).to have_content("1.\nHandsomeDan Bulldog")
      expect(content).to have_content("2.\nRhett Lecheire")
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        expect(page).to have_content("Collection Order")
        click_on "Collection Order"
      end
      content = find(:css, '#content')
      expect(content).to have_content("1.\nRhett Lecheire")
      expect(content).to have_content("2.\nHandsomeDan Bulldog")
    end
  end
end
