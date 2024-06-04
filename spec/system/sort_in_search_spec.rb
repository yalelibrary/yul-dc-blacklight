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

  # rubocop:disable Layout/LineLength
  context 'sorts by title' do
    it 'asc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Title (A --> Z)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("Amor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho").or have_content("1.\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\n2.\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\n3.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n4.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho")
    end

    it 'desc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Title (Z --> A)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("Rhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney").or have_content("1.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\n2.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n3.\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\n4.\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney")
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
      expect(content).to have_content("Aquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho").or have_content("1.\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\n2.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n3.\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\n4.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho")
    end

    it 'sorts by creator desc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Creator (Z --> A)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("Rhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss").or have_content("1.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\n2.\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\n3.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n4.\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss")
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
      expect(content).to have_content("Amor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss").or have_content("1.\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney\n2.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n3.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\n4.\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss")
    end

    it 'sorts by year desc' do
      click_on 'search'
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        click_on 'Year (descending)'
      end

      content = find(:css, '#content')
      expect(content).to have_content("Aquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney").or have_content("1.\nAquila Eccellenza\nSave Item\nCreator:\nAndrew Norriss\n2.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\n3.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n4.\nAmor Llama\nSave Item\nCreator:\nAnna Elizabeth Dewdney")
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
    # flappy - passes locally and sometimes in CI
    xit 'does not have sort by collection by default' do
      visit "/catalog?f[collection_title_ssi][]=Test"
      content = find(:css, '#content')
      expect(content).to have_content("HandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho").or have_content("1.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n2.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho")
      click_on 'Sort by relevance'
      within('div#sort-dropdown') do
        expect(page).to have_content("Collection Order")
        click_on "Collection Order"
      end
      content = find(:css, '#content')
      expect(content).to have_content("Rhett Lecheire\nSave Item\nCreator:\nPaulo Coelho\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves").or have_content("1.\nHandsomeDan Bulldog\nSave Item\nCreator:\nAndy Graves\n2.\nRhett Lecheire\nSave Item\nCreator:\nPaulo Coelho")
    end
  end
  # rubocop:enable Layout/LineLength
end
