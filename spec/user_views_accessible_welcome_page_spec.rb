# frozen_string_literal: true
require 'spec_helper'
require 'rspec/rails'
require 'axe/rspec'

feature 'welcome', js: true do
  context 'landing page is accessible' do
    it 'prototype working axe gem on landing page' do
      visit "/"
      expect(page).to be_accessible
    end
  end
end
