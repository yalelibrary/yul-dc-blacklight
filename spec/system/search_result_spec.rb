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

    it 'shows the index number' do
      expect(find('#documents > .document-position-0 span')).to be_visible
    end
  end

  context 'in gallery view' do
    before do
      visit '/?q=&search_field=all_fields&view=gallery'
    end

    it 'has expected css' do
      expect(page).to have_css '.index'
      expect(page).to have_css '.caption'
    end
  end
end
