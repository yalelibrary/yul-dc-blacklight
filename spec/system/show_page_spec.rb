# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'single items page', type: :system, clean: true do
  before do
    visit '/'
  end

  # it 'has expected css' do
  #   expect(page).to have_css('.card')
  #   page.has_css?('.list-group')
  #   # expect(page).to have_css('.list-group')
  #   expect(page).to have_css('.list-group-item')
  #   expect(page).to have_css('.show-links')
  #   expect(page).to have_css('.show-tools')
  #   expect(page).to have_css('.iiif-logo')
  # end

  it 'has expected button' do
    expect(page).to have_link('email')
    expect(page).to have_link('citation')
    expect(page).to have_link('sms')
    expect(page).to have_link('manifest')

    # expect(page).to have_button('#emailLink')
    # expect(page).to have_button('#citationLink')
    # expect(page).to have_button('#smsLink')
    # expect(page).to have_button('#manifestLink')
  end
end
