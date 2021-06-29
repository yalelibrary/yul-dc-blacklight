# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results displays field', type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat])
    solr.commit
    visit '/catalog?search_field=all_fields&q='
  end

  let(:search_fields) { CatalogController.blacklight_config.search_fields.keys }
  let(:expected_search_fields) do
    ["all_fields", "all_fields_advanced", "creator_tesim", "child_oids_ssim", "date_fields", "genre_fields",
     "callNumber_tesim", "oid_ssi", "fulltext_tsim_advanced", "orbisBibId_ssi", "fulltext_tesim", "subjectName_tesim", "subject_fields", "title_tesim"]
  end

  let(:dog) do
    {
      id: '111',
      title_tesim: 'Handsome Dan is a bull dog.',
      creator_tesim: 'Eric & Frederick',
      fulltext_tesim: ['fulltext text one'],
      subjectName_tesim: "this is the subject name",
      sourceTitle_tesim: "this is the source title",
      callNumber_tesim: 'WAMSS987',
      orbisBibId_ssi: '1238901',
      visibility_ssi: 'Public'
    }
  end

  let(:cat) do
    {
      id: '212',
      title_tesim: 'Handsome Dan is not a cat.',
      creator_tesim: 'Frederick & Eric',
      fulltext_tesim: ['fulltext text two'],
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      subjectName_tesim: "WAMSS987",
      callNumber_tesim: 'Yale MS 123',
      visibility_ssi: 'Public'
    }
  end

  context 'search fields' do
    it ' contains all search fields in the view' do
      expect(search_fields).to contain_exactly(*expected_search_fields)
    end

    it 'displays the correct record when searching by call number' do
      visit '/catalog?search_field=callNumber_tesim&q=WAMSS987'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).not_to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct record when searching by BibId' do
      visit '/catalog?search_field=orbisBibId_ssi&q=1238901'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).not_to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct record when searching by creator' do
      visit '/catalog?search_field=creator&q=Eric'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct record when searching by subject' do
      visit '/catalog?search_field=subjectName_tesim&q=this+is+the+subject+name'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).not_to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct record when searching by a subject name that appears in call number' do
      visit '/catalog?search_field=subjectName_tesim&q=WAMSS987'
      expect(page).not_to have_content 'Handsome Dan is a bull dog.'
      expect(page).to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct record when searching by title' do
      visit '/catalog?search_field=title_tesim&q=handsome'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct records when searching by fulltext' do
      visit '/catalog?search_field=fulltext_tesim&q=fulltext'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).to have_content 'Handsome Dan is not a cat.'
    end

    it 'displays the correct record when searching by fulltext' do
      visit '/catalog?search_field=fulltext_tesim&q=one'
      expect(page).to have_content 'Handsome Dan is a bull dog.'
      expect(page).not_to have_content 'Handsome Dan is not a cat.'
    end

    it 'adds the fulltext  simple search description' do
      visit search_catalog_path
      select('Full Text', from: 'search_field')
      expect(page).to have_content 'Search full text that occurs in a work. Not all works contain searchable full text.'
    end
  end
end
describe 'Description/Fulltext Radio Buttons',:js do
  context '"Fulltext"' do
    before do
      visit 'catalog/'

      select 'Title', from: 'search_field'
      choose 'fulltext_search_2'
    end

    it 'has correct Placeholder text for search bar' do
      search = page.find('#q')
      expect(search[:placeholder]).to have_text 'Search words within the items'
    end

    it 'hides the search fields while selected' do
      expect(page).not_to have_selector("#search_field", visible:true)
    end
    it 'returns to last selected field when switching to "Description"' do
      choose 'fulltext_search_1'

      expect(page).to have_select 'search_field', selected: 'Title'
    end
  end
  context '"Description"' do
    before do
      visit 'catalog/'
    end
    it 'shows search fields while selected' do
      expect(page).to have_selector("#search_field", visible:true)
    end
    it 'has correct Placeholder text for search bar for All Fields' do
      search = page.find('#q')
      expect(search[:placeholder]).to have_text 'Search words about the items'
    end
    it 'has correct Placeholder text for search bar specific fields' do
      search = page.find('#q')
      expect(search[:placeholder]).to have_text 'Search'
    end
    it 'should be clicked by default' do
      expect(page).to have_checked_field  'fulltext_search_1'
    end
    it 'displays the search fields while selected' do
      expect(page).to have_selector("#search_field", visible:true)
    end
  end
end
