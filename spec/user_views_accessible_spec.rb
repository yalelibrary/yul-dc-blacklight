# frozen_string_literal: true
require 'spec_helper'
require 'rspec/rails'
require 'axe/rspec'

feature 'welcome', js: true do
  context 'landing page is accessible' do
    it 'with axe gem' do
      visit "/"
      expect(page).to be_accessible
    end
  end
  context 'bookmarks page is accessible' do
    it 'with axe gem' do
      visit "/bookmarks"
      expect(page).to be_accessible
    end
  end
end
