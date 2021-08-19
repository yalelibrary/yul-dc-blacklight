# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Description/Fulltext Radio Buttons', type: :system, js: true do
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
      expect(page).not_to have_selector("#search_field", visible: true)
    end
    it 'returns to "All Fields" when switching to "Description"' do
      choose 'fulltext_search_1'

      expect(page).to have_select 'search_field', selected: 'All Fields'
    end
  end
  context '"Description"' do
    before do
      visit 'catalog/'
    end
    it 'has correct Placeholder text for search bar for All Fields' do
      search = page.find('#q')
      expect(search[:placeholder]).to have_text 'Search words about the items'
    end
    it 'has correct Placeholder text for search bar specific fields' do
      search = page.find('#q')
      expect(search[:placeholder]).to have_text 'Search'
    end
    it 'is clicked by default' do
      expect(page).to have_checked_field 'fulltext_search_1'
    end
    it 'displays the search fields while selected' do
      expect(page).to have_selector("#search_field", visible: true)
    end
  end
end
