# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "Citation Helper", helper: true, clean: true, system: true do
  let(:test_record) do
    {
      id: '111',
      title_tesim: 'Handsome Dan',
      edition_tesim: 'First Edition',
      subtitle_tesim: "He's handsome",
      subtitle_vern_ssim: "He's handsome",
      creator_tesim: 'Eric & Frederick',
      creator_ssim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/111',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/111',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      abstract_tesim: "this is an abstract",
      alternativeTitle_tesim: "this is an alternative title",
      genre_ssim: "this is the genre",
      geoSubject_ssim: "this is the geo subject",
      resourceType_ssim: "this is the resource type",
      subjectName_ssim: "this is the subject name",
      subjectTopic_tesim: "this is the subject topic",
      extentOfDigitization_ssim: 'this is the extent of digitization',
      rights_ssim: "these are the rights",
      publicationPlace_ssim: "this is the publication place",
      sourceCreated_tesim: "this is the source created",
      publisher_ssim: "this is the publisher",
      copyrightDate_ssim: "this is the copyright date",
      source_ssim: "this is the source",
      recordType_ssi: "this is the record type",
      sourceTitle_tesim: "this is the source title",
      sourceDate_tesim: "this is the source date",
      sourceNote_tesim: "this is the source note",
      references_tesim: "these are the references",
      date_ssim: "this is the date",
      children_ssim: "these are the children",
      importUrl_ssim: "this is the import URL",
      illustrativeMatter_tesim: "this is the illustrative matter",
      oid_ssi: 'this is the OID',
      identifierMfhd_ssim: 'this is the identifier MFHD',
      identifierShelfMark_tesim: 'this is the Call Number',
      containerGrouping_ssim: 'this is the container grouping',
      folder_ssim: 'this is the folder',
      orbisBibId_ssi: 'this is the orbis bib ID',
      findingAid_ssim: 'this is the finding aid',
      collectionId_ssim: 'this is the collection ID',
      edition_ssim: 'this is the edition',
      uri_ssim: 'this is the URI',
      partOf_ssim: "this is the part of, using ssim",
      numberOfPages_ssim: "this is the number of pages, using ssim",
      material_tesim: "this is the material, using ssim",
      scale_tesim: "this is the scale, using ssim",
      digital_ssim: "this is the digital, using ssim",
      coordinates_ssim: "this is the coordinates, using ssim",
      projection_tesim: "this is the projection, using ssim",
      extent_ssim: "this is the extent, using ssim"
    }
  end

  context 'Clicking on cite' do
    before do
      solr = Blacklight.default_index.connection
      solr.add([test_record])
      solr.commit
      visit '/catalog/111'
    end

    it 'displays correct MLA citation' do
      click_on "Cite"
      expect(page).to have_css('#mla-citation')

      within('#mla-citation') do
        expect(page).to have_content('MLA')
        expect(page).to have_content("Eric, and Frederick. Handsome Dan. First Edition, this is the publisher, 0AD. http://collections-demo.curationexperts.com/catalog/111.")
      end
    end

    it 'displays correct APA citation' do
      click_on "Cite"
      expect(page).to have_css('#apa-citation')

      within('#apa-citation') do
        expect(page).to have_content('APA, 6th edition')
        expect(page).to have_content("E., & F. (0 C.E.). Handsome Dan (First Edition) [This is the genre]. this is the publisher. http://collections-demo.curationexperts.com/catalog/111.")

        expect(page).not_to have_content('this is the publisher http://collections-demo.curationexperts.com/catalog/111.')
      end
    end

    context 'with creators that do not have abnormal characters' do
      before do
        solr = Blacklight.default_index.connection
        test_record[:creator_ssim] = 'Alisha Evans'
        solr.add([test_record])
        solr.commit
        visit '/catalog/111'
      end

      it 'displays correct MLA citation' do
        click_on "Cite"
        expect(page).to have_css('#mla-citation')

        within('#mla-citation') do
          expect(page).to have_content('Evans, Alisha.')
        end
      end

      it 'displays correct APA citation' do
        click_on "Cite"
        expect(page).to have_css('#apa-citation')

        within('#apa-citation') do
          expect(page).to have_content('Evans, A.')
        end
      end
    end
  end
end
