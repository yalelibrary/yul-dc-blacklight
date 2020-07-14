require 'spec_helper'
require 'rspec/rails'
require 'axe/rspec'

feature 'welcome', js: true do
  scenario 'index is accessible' do
    visit "/"
    expect(page).to  be_accessible
  end
end