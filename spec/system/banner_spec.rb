# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Banner', type: :system, js: true, clean: true do
  before do
    visit "/catalog"
  end

  context 'when viewing page' do
    it 'is visible' do
      expect(page).to have_css("#banner")
    end

    it 'does not create duplicates if renderBanner() is called again' do
      page.evaluate_script('renderBanner()')
      expect(page.evaluate_script('$("#banner h3").length')).to eq(1)
    end
  end
end
