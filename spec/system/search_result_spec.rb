# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'search result', type: :system do
  context 'in list view' do
    before do
      visit '/?search_field=all_fields&view=list'
    end

    it 'has expected css' do
      expect(page).to have_css '.dl-invert'
      expect(page).to have_css '.document-metadata'
    end

    it 'has the correct "per page" options' do
      expect(page).to have_text '10 per page 20 per page 50 per page 100 per page'
    end
  end

  context 'in gallery view' do
    before do
      visit '/?q=&search_field=all_fields&view=gallery'
    end

    it 'has expected css' do
      expect(page).to have_css '.caption'
    end

    it 'has the correct "per page" options' do
      expect(page).to have_text '9 per page 30 per page 60 per page 99 per page'
    end
  end
end
