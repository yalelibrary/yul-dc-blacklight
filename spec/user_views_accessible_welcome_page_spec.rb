# frozen_string_literal: true
require 'spec_helper'
require 'rspec/rails'
require 'axe/rspec'

feature 'welcome', js: true do
  scenario 'index is accessible' do
    pending 'prototype working axe gem on landing page'
    visit "/"
    expect(page).to be_accessible
  end
end
