# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "Citation Helper", helper: true, clean: true, system: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record])
    solr.commit
    visit '/catalog/111'
  end

  let(:test_record) do
    {
      id: '111',
      subtitle_tsim: "He's handsome",
      subtitle_vern_ssim: "He's handsome",
      author_tsim: 'Eric & Frederick',
      author_ssim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/111',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/111',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      lc_callnum_ssim: "123213213",
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      abstract_ssim: "this is an abstract",
      alternativeTitle_ssim: "this is an alternative title",
      genre_ssim: "this is the genre",
      geoSubject_ssim: "this is the geo subject",
      resourceType_ssim: "this is the resource type",
      subjectName_ssim: "this is the subject name",
      subjectTopic_ssim: "this is the subject topic",
      extentOfDigitization_ssim: 'this is the extent of digitization',
      rights_ssim: "these are the rights",
      publicationPlace_ssim: "this is the publication place",
      sourceCreated_ssim: "this is the source created",
      publisher_ssim: "this is the publisher",
      copyrightDate_ssim: "this is the copyright date",
      source_ssim: "this is the source",
      recordType_ssim: "this is the record type",
      sourceTitle_ssim: "this is the source title",
      sourceDate_ssim: "this is the source date",
      sourceNote_ssim: "this is the source note",
      references_ssim: "these are the references",
      date_tsim: "this is the date",
      children_ssim: "these are the children",
      importUrl_ssim: "this is the import URL",
      illustrativeMatter_ssim: "this is the illustrative matter",
      oid_ssim: 'this is the OID',
      identifierMfhd_ssim: 'this is the identifier MFHD',
      identifierShelfMark_ssim: 'this is the identifier shelf mark',
      box_ssim: 'this is the box',
      folder_ssim: 'this is the folder',
      orbisBibId_ssim: 'this is the orbis bib ID',
      orbisBarcode_ssim: 'this is the orbis bar code',
      findingAid_ssim: 'this is the finding aid',
      collectionId_ssim: 'this is the collection ID',
      edition_ssim: 'this is the edition',
      # edition_tesim: 'this is the edition',
      uri_ssim: 'this is the URI',
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

  context 'Clicking on cite' do
    it 'displays correct MLA citation' do
      click_on "Cite"
      expect(page).to have_css('#mla-citation')

      within('#mla-citation') do
        expect(page).to have_content('MLA')
        expect(page).to have_content("Eric, and Frederick. this is the publisher, 0AD. http://collections-demo.curationexperts.com/catalog/111.")
      end
    end

    it 'displays correct APA citation' do
      click_on "Cite"
      expect(page).to have_css('#mla-citation')

      within('#apa-citation') do
        expect(page).to have_content('APA, 6th edition')
        expect(page).to have_content("E., & F. (0 C.E.). [This is the genre]. this is the publisher. http://collections-demo.curationexperts.com/catalog/111.")

        expect(page).not_to have_content('this is the edition')
      end
    end
  end
end
