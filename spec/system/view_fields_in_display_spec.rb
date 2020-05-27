# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "View Search Results", type: :system, clean: true, js: false do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record])
    solr.commit
    visit '/catalog/111'
  end

  let(:test_record) do
    {
      id: '111',
      title_tsim: ['HandsomeDan Bulldog'],
      title_vern_ssim: ['HandsomeDan Bulldog'],
      subtitle_tsim: "He's handsome",
      subtitle_vern_ssim: "He's handsome",
      author_tsim: 'Eric & Frederick',
      author_vern_ssim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/111',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/111',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      lc_callnum_ssim: "123213213",
      language_ssim: 'en',
      isbn_ssim: '2321321389',
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      public_bsi: 1,
      abstract_ssim: "this is an abstract",
      alternativeTitle_ssim: "this is an alternative title",
      genre_ssim: "this is the genre",
      geoSubject_ssim: "this is the geo subject",
      resourceType_ssim: "this is the resource type",
      subjectName_ssim: "this is the subject name",
      subjectTopic_ssim: "this is the subject topic",
      partOf_ssim: "this is the part of, using ssim",
      numberOfPages_ssim: "this is the number of pages, using ssim",
      material_ssim: "this is the material, using ssim",
      scale_ssim: "this is the scale, using ssim",
      digital_ssim: "this is the digital, using ssim",
      coordinates_ssim: "this is the coordinates, using ssim",
      projection_ssim: "this is the projection, using ssim",
      extent_ssim: "this is the extent, using ssim"
    }
  end

  it 'displays Author in results' do
    expect(page).to have_content("Eric & Frederick").twice
  end
  it 'displays Title in results' do
    expect(page).to have_content("HandsomeDan Bulldog", count: 3)
  end
  it 'displays Subtitle in results' do
    expect(page).to have_content("He's handsome").twice
  end
  it 'displays Url Fulltext in results' do
    expect(page).to have_content("http://0.0.0.0:3000/catalog/111").twice
  end
  it 'displays Publishing in results' do
    expect(page).to have_content("1997").twice
  end
  it 'displays format in results' do
    expect(page).to have_content("three dimensional object")
  end
  it 'displays extent in results' do
    expect(page).to have_content("this is the extent, using ssim")
  end
  it 'displays part of in results' do
    expect(page).to have_content("this is the part of, using ssim")
  end
  it 'displays number of page in results' do
    expect(page).to have_content("this is the number of pages, using ssim")
  end
  it 'displays material in results' do
    expect(page).to have_content("this is the material, using ssim")
  end
  it 'displays scale in results' do
    expect(page).to have_content("this is the scale, using ssim")
  end
  it 'displays digital in results' do
    expect(page).to have_content("this is the digital, using ssim")
  end
  it 'displays coordinates in results' do
    expect(page).to have_content("this is the coordinates, using ssim")
  end
  it 'displays projection in results' do
    expect(page).to have_content("this is the projection, using ssim")
  end
  it 'displays call number in results' do
    expect(page).to have_content("123213213")
  end
  it 'displays language in results' do
    expect(page).to have_content("en")
  end
  it 'displays ISBN in results' do
    expect(page).to have_content("2321321389")
  end
  it 'displays description in results' do
    expect(page).to have_content("Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.")
  end
  it 'displays the Abstract in results' do
    expect(page).to have_content("this is an abstract")
  end
  it 'displays the Alternative Title in results' do
    expect(page).to have_content("this is an alternative title")
  end
  it 'displays the Genre in results' do
    expect(page).to have_content("this is the genre")
  end
  it 'displays the Geo Subject in results' do
    expect(page).to have_content("this is the geo subject")
  end
  it 'displays the Resource Type in results' do
    expect(page).to have_content("this is the resource type")
  end
  it 'displays the Subject Name in results' do
    expect(page).to have_content("this is the subject name")
  end
  it 'displays the Subject Topic in results' do
    expect(page).to have_content("this is the subject topic")
  end
end
