# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'header', type: :system do
  before do
    visit '/'
  end

  it 'has expected css' do
    expect(page).to have_css '.bg-dark'
    expect(page).to have_css '.dropdown-menu'
    expect(page).to have_css '.info-header'
    expect(page).to have_css '.nav-link'
    expect(page).to have_css '.navbar-brand'
    expect(page).to have_css '.navbar-logo'
    expect(page).to have_css '.secondary-nav'
    expect(page).to have_css 'div#secondary-nav row'
    expect(page).to have_css '.secondary-nav a'
  end

  it 'has expected links' do
    expect(page).to have_link('Ask Yale Library', href: 'http://ask.library.yale.edu/')
    expect(page).to have_link('Reserve Rooms', href: 'https://schedule.yale.edu/')
    expect(page).to have_link('Places to Study', href: 'https://web.library.yale.edu/places/to-study')
    expect(page).to have_link('Yale University Library', href: '/')
  end

  it 'has expected Yale log branding' do
    expect(page.find('.navbar-logo')['//app/images/yul_logo/'])
  end
end
