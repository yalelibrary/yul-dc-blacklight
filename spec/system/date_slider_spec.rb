# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Blacklight Range Limit", type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat, bird])
    solr.commit
  end

  let(:dog) do
    {
      id: '111',
      title_tesim: 'Handsome Dan is a bull dog.',
      dateStructured_ssim: '2022',
      author_tesim: 'Eric & Frederick',
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
      dateStructured_ssim: '1600',
      author_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  let(:bird) do
    {
      id: '313',
      title_tesim: 'Handsome Dan is not a bird.',
      dateStructured_ssim: '1100',
      author_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  it "shows the range limit facet" do
    visit root_path
    click_button 'PUBLICATION DATE'

    expect(page).to have_selector '.range_begin'
    expect(page).to have_selector '.range_end'
    expect(page).to have_button 'Apply'
  end

  it "provides date information" do
    visit root_path
    click_button 'PUBLICATION DATE'

    expect(page).to have_content("1100 to 2022")
  end

  xit "should be able to search with the slider" do
    visit root_path
    click_button 'PUBLICATION DATE'
    within '.card.facet-limit.blacklight-dateStructured_ssim' do
      source = page.find('.slider-handle.round').last
      source.drag_by(30, 0)
    end

    within '.blacklight-dateStructured_ssim' do
      expect(page).to have_content "1100 to 1600"
    end

    within '.constraints-container' do
      expect(page).to have_content '1100 to 1600'
    end

    expect(page).to have_content '1 - 3'
  end
end
