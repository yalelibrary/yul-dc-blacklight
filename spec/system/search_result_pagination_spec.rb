# frozen_string_literal: true

RSpec.describe "search result pagination", type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog, cat, bird])
    solr.commit
  end

  let(:dog) do
    {
      id: '111',
      title_tesim: 'Handsome Dan is a bull dog.',
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
      creator_tesim: 'Frederick & Eric',
      sourceTitle_tesim: "this is the source title",
      orbisBibId_ssi: '1234567',
      visibility_ssi: 'Public'
    }
  end

  it "displays no pagination when search results are less than per page cap" do
    # default per page cap is 10 and there are 3 search results
    visit '/catalog?search_field=all_fields&view=list'
    # this double arrow is the last page link in the bottom pagination
    expect(page).not_to have_link "»"
  end

  it 'displays pagination when search results are greater than per page cap"' do
    # sets per page cap to 2 and there are 3 search results
    visit '/catalog?per_page=2&q=&search_field=all_fields'
    # last page link
    expect(page).to have_link "»"
  end

  context "navigating with search context links" do
    it "has the appropriate context links on the first page of results" do
      visit '/catalog?per_page=2&q=&search_field=all_fields'
      within 'ul.pagination' do
        # PREVIOUS and « are disabled on the first page, so they render as text
        expect(page).not_to have_link "PREVIOUS"
        expect(page).to have_css 'li.page-item.disabled span.page-link', text: 'PREVIOUS'
        expect(page).not_to have_link "«"
        expect(page).to have_link "»"
        expect(page).to have_link "NEXT"
      end
    end

    it "jumps to last page of results" do
      visit '/catalog?per_page=2&q=&search_field=all_fields'
      click_on "»"
      within 'ul.pagination' do
        # NEXT and » are disabled on the last page, so they render as text
        expect(page).not_to have_link "NEXT"
        expect(page).to have_css 'li.page-item.disabled span.page-link', text: 'NEXT'
        expect(page).not_to have_link "»"
        expect(page).to have_link "PREVIOUS"
        expect(page).to have_link "«"
      end
    end

    it "jumps to first page of results" do
      visit '/catalog?per_page=2&q=&search_field=all_fields'
      click_on "»"
      click_on "«"
      within 'ul.pagination' do
        # back on the first page, PREVIOUS and « render as text again
        expect(page).not_to have_link "PREVIOUS"
        expect(page).to have_css 'li.page-item.disabled span.page-link', text: 'PREVIOUS'
        expect(page).not_to have_link "«"
        expect(page).to have_link "NEXT"
      end
    end
  end
end
