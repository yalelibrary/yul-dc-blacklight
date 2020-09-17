# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "View Search Results", type: :system, clean: true, js: false do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record,
              same_call_record,
              diff_call_record])
    solr.commit
    visit '/catalog/111'
  end

  let(:same_call_record) do
    {
      id: '222',
      visibility_ssi: 'Public',
      identifierShelfMark_ssim: 'this is the call number'
    }
  end

  let(:diff_call_record) do
    {
      id: '333',
      visibility_ssi: 'Public',
      identifierShelfMark_ssim: 'this is the call number, but different'
    }
  end

  let(:test_record) do
    {
      id: '111',
      title_tesim: "Diversity Bull Dogs",
      subtitle_tesim: "He's handsome",
      subtitle_vern_ssim: "He's handsome",
      author_tesim: 'Eric & Frederick',
      author_vern_ssim: 'Eric & Frederick',
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
      abstract_tesim: "this is an abstract",
      alternativeTitle_tesim: "this is an alternative title",
      genre_ssim: "this is the genre",
      geoSubject_ssim: "this is the geo subject",
      resourceType_ssim: "this is the resource type",
      subjectName_ssim: "this is the subject name",
      subjectTopic_ssim: "this is the subject topic",
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
      oid_ssi: '2345678',
      identifierMfhd_ssim: 'this is the identifier MFHD',
      identifierShelfMark_ssim: 'this is the call number',
      box_ssim: 'this is the box',
      folder_ssim: 'this is the folder',
      orbisBibId_ssi: '1234567',
      orbisBarcode_ssi: 'this is the orbis bar code',
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

  context 'Within main document' do
    subject(:document) { find(:css, '#document') }
    it 'displays Title in results' do
      expect(document).to have_content("Diversity Bull Dogs")
    end
    it 'displays Author in results' do
      expect(document).to have_content("Eric & Frederick")
    end
    it 'displays Subtitle in results' do
      expect(document).to have_content("He's handsome")
    end
    it 'displays Url Fulltext in results' do
      expect(document).to have_content("http://0.0.0.0:3000/catalog/111").twice
    end
    it 'displays Publishing in results' do
      expect(document).to have_content("1997").twice
    end
    it 'displays format in results' do
      expect(document).to have_content("three dimensional object")
    end
    it 'displays extent in results' do
      expect(document).to have_content("this is the extent, using ssim")
    end
    it 'displays part of in results' do
      expect(document).to have_content("this is the part of, using ssim")
    end
    it 'displays number of page in results' do
      expect(document).to have_content("this is the number of pages, using ssim")
    end
    it 'displays material in results' do
      expect(document).to have_content("this is the material, using ssim")
    end
    it 'displays scale in results' do
      expect(document).to have_content("this is the scale, using ssim")
    end
    it 'displays digital in results' do
      expect(document).to have_content("this is the digital, using ssim")
    end
    it 'displays coordinates in results' do
      expect(document).to have_content("this is the coordinates, using ssim")
    end
    it 'displays projection in results' do
      expect(document).to have_content("this is the projection, using ssim")
    end
    it 'displays call number in results' do
      expect(document).to have_content("123213213")
    end
    it 'displays language in results' do
      expect(document).to have_content("English (en)")
      expect(document).to have_content("English (eng)")
      expect(document).to have_content("zz")
    end
    it 'displays ISBN in results' do
      expect(document).to have_content("2321321389")
    end
    it 'displays description in results' do
      expect(document).to have_content("Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.")
    end
    it 'displays the Abstract in results' do
      expect(document).to have_content("this is an abstract")
    end
    it 'displays the Alternative Title in results' do
      expect(document).to have_content("this is an alternative title")
    end
    it 'displays the Genre in results' do
      expect(document).to have_content("this is the genre")
    end
    it 'displays the Geo Subject in results' do
      expect(document).to have_content("this is the geo subject")
    end
    it 'displays the Resource Type in results' do
      expect(document).to have_content("this is the resource type")
    end
    it 'displays the Subject Name in results' do
      expect(document).to have_content("this is the subject name")
    end
    it 'displays the Extend of Digitization in results' do
      expect(document).to have_content("this is the extent of digitization")
    end
    it 'displays the Rights in results' do
      expect(document).to have_content("these are the rights")
    end
    it 'displays the Publication Place in results' do
      expect(document).to have_content("this is the publication place")
    end
    it 'displays the Source Created in results' do
      expect(document).to have_content("this is the source created")
    end
    it 'displays the Publisher in results' do
      expect(document).to have_content("this is the publisher")
    end
    it 'displays the Copyright Date in results' do
      expect(document).to have_content("this is the copyright date")
    end
    it 'displays the Source in results' do
      expect(document).to have_content("this is the source")
    end
    it 'displays the Record Type in results' do
      expect(document).to have_content("this is the record type")
    end
    it 'displays the Source Title in results' do
      expect(document).to have_content("this is the source title")
    end
    it 'displays the Source Date in results' do
      expect(document).to have_content("this is the source date")
    end
    it 'displays the Source Note in results' do
      expect(document).to have_content("this is the source note")
    end
    it 'displays the References in results' do
      expect(document).to have_content("these are the references")
    end
    it 'displays the Date in results' do
      expect(document).to have_content("this is the date")
    end
    it 'displays the Children in results' do
      expect(document).to have_content("these are the children")
    end
    it 'displays the import URL in results' do
      expect(document).to have_content("this is the import URL")
    end
    it 'displays the Illustrative Matter in results' do
      expect(document).to have_content("this is the illustrative matter")
    end
    it 'displays the OID in results' do
      expect(document).to have_content("2345678")
    end
    it 'displays the Identifier MFHD in results' do
      expect(document).to have_content("this is the identifier MFHD")
    end
    it 'displays the Box in results' do
      expect(document).to have_content("this is the box")
    end
    it 'displays the Folder in results' do
      expect(document).to have_content("this is the folder")
    end
    it 'displays the Orbis Bib ID in results' do
      expect(document).to have_content("1234567")
    end
    it 'displays the Orbis Bar Code in results' do
      expect(document).to have_content("this is the orbis bar code")
    end
    it 'displays the Finding Aid in results' do
      expect(document).to have_content("this is the finding aid")
    end
    it 'displays the Collection ID in results' do
      expect(document).to have_content("this is the collection ID")
    end
    it 'displays the Edition in results' do
      expect(document).to have_content("this is the edition")
    end
    it 'displays the URI in results' do
      expect(document).to have_content("this is the URI")
    end
    it 'displays the call number in results as link' do
      expect(page).to have_link("this is the call number", href: '/?f%5BidentifierShelfMark_ssim%5D%5B%5D=this+is+the+identifier+shelf+mark')
      expect(page).not_to have_link("this is the call number", href: '/?f%5BidentifierShelfMark_ssim%5D%5B%5D=this+is+the+identifier+shelf+mark+but+different')
    end
    it 'contains a link on genre to its facet' do
      expect(page).to have_link('this is the genre', href: '/?f%5Bgenre_ssim%5D%5B%5D=this+is+the+genre')
    end
    it 'contains a link on format to its facet' do
      expect(page).to have_link('three dimensional object', href: '/?f%5Bformat%5D%5B%5D=three+dimensional+object')
    end
    it 'contains a link on resource type to its facet' do
      expect(page).to have_link('this is the resource type', href: '/?f%5BresourceType_ssim%5D%5B%5D=this+is+the+resource+type')
    end
    it 'contains a link on language to its facet' do
      expect(page).to have_link('English (en)', href: '/?f%5Blanguage_ssim%5D%5B%5D=English (en)')
      expect(page).to have_link('English (eng)', href: '/?f%5Blanguage_ssim%5D%5B%5D=English (eng)')
      expect(page).to have_link('zz', href: '/?f%5Blanguage_ssim%5D%5B%5D=zz')
    end
    it 'contains a link on the Orbis Bib ID to the Orbis catalog record' do
      expect(page).to have_link('1234567', href: 'http://hdl.handle.net/10079/bibid/1234567')
    end
    it 'contains a link on the Finding Aid to the Finding Aid catalog record' do
      expect(page).to have_link('this is the finding aid', href: 'this is the finding aid')
    end
  end

  it 'has expected css' do
    expect(page).to have_css '.card'
    expect(page).to have_css '.iiif-logo'
    expect(page).to have_css '.list-group'
    expect(page).to have_css '.list-group-item'
    expect(page).to have_css '.show-links'
    expect(page).to have_css '.show-tools'
    expect(page).to have_css '.show-header'
    expect(page).to have_css '.universal-viewer-iframe'
  end
end
