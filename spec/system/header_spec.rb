# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'header', type: :system do
  before do
    visit '/'
  end

  it 'has expected css' do
    expect(page).to have_css '.nav-link'
    expect(page).to have_css '.bg-dark'
  end

  it 'has expected links' do
    expect(page).to have_link('Ask Yale Library', href: 'http://ask.library.yale.edu/')
    expect(page).to have_link('Reserve Rooms', href: 'https://schedule.yale.edu/')
    expect(page).to have_link('Places to Study', href: 'https://web.library.yale.edu/places/to-study')
  end
end
