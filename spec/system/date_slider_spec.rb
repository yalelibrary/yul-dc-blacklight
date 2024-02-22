# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Blacklight Range Limit", type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat, bird, rabbit, elephant, turtle])
    solr.commit
  end

  let(:dog) do
    {
      id: '111',
      title_tesim: 'Handsome Dan is a bull dog.',
      year_isim: [2023],
      creator_tesim: 'Eric & Frederick',
      subjectName_ssim: "this is the subject name",
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1238901',
      visibility_ssi: 'Public'
    }
  end

  let(:cat) do
    {
      id: '212',
      title_tesim: 'Handsome Dan is not a cat.',
      year_isim: [1600, 1601, 1603],
      creator_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  let(:bird) do
    {
      id: '313',
      title_tesim: 'Handsome Dan is not a bird.',
      year_isim: [1100, 1101, 1102],
      creator_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  let(:rabbit) do
    {
      id: '400',
      callNumber_ssim: 'call number',
      title_tesim: 'Handsome Dan is not a rabbit.',
      year_isim: [1555, 1556, 1557],
      creator_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  let(:elephant) do
    {
      id: '401',
      callNumber_ssim: 'unique call number',
      title_tesim: 'Handsome Dan is not a elephant.',
      year_isim: [1555],
      creator_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  let(:turtle) do
    {
      id: '402',
      title_tesim: 'Handsome Dan is not a turtle.',
      year_isim: (1555..1800).to_a,
      creator_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  it "shows the range limit facet" do
    visit search_catalog_path
    click_button 'Date Created'

    expect(page).to have_selector '.facet-field-heading'
    expect(page).to have_selector '.range-limit-input-group'
    expect(page).to have_selector '.range_begin'
    expect(page).to have_selector '.range_end'
    expect(page).to have_button 'Apply'
  end

  it "provides date information" do
    visit search_catalog_path
    click_button 'Date Created'
    el = page.find(:css, '.slider.slider-horizontal > .tooltip.top.hide > .tooltip-inner', visible: false)
    expect(el).to have_content("1100 : 2023")
  end

  it "does not show the date slider if only one date" do
    visit '/catalog?search_field=callNumber_ssim&q="unique call number"'
    expect(page).not_to have_css('.card.facet-limit.blacklight-year_isim')
  end

  xit "is able to search with the slider", :style, style: true, js: true do
    visit search_catalog_path
    click_button 'Date Created'
    within '#facet-year_isim' do
      sliders = find_all('.slider-handle.round')

      beg_slider = sliders.first
      beg_slider.drag_by(5, 0)

      end_slider = sliders.last
      end_slider.drag_by(-70, 0)
    end
    within '#facet-year_isim' do
      click_on 'Apply', match: :first
    end

    within '.blacklight-year_isim' do
      expect(page.text).to match(/11\d\d to 16\d\d/)
    end

    within '.constraints-container' do
      expect(page.text).to match(/Date Created 11\d\d To 16\d\d/)
    end

    # makes sure that it includes the turtle record with years: 1555-1800
    expect(page).to have_content '1 - 4'
  end
end
