# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Banner', type: :system, js: true, clean: true do
  before do
    visit "/catalog"
  end

  context 'when viewing page' do
    xit 'is visible' do
      expect(page).to have_css("#banner")
    end

    xit 'does not create duplicates if renderBanner() is called again' do
      page.evaluate_script('renderBanner()')
      expect(page).to have_css("#banner")
      expect(page.evaluate_script('$("#banner p").length')).to eq(1)
    end
  end
end
