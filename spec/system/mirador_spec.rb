# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Mirador viewer', type: :system do
  context 'Configure Mirador' do
    it 'configures a manifest given an integer value' do
      value = 123_456
      visit "/mirador/#{value}"
      expect(page.html).to match(/const manifest =.*#{value}/)
    end

    it 'contains a noindex tag' do
      value = 123_456
      visit "/mirador/#{value}"
      expect(page.html).to include('<meta name="robots" content="noindex">')
    end

    it 'builds a blank configuration given an invalid value' do
      value = '1_malicious_stuff_here'
      visit "/mirador/#{value}"
      expect(page.html).not_to match(/const manifest/)
      expect(page.html).not_to include value
    end
  end
end
