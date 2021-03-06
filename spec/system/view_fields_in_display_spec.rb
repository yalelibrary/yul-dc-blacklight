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
      callNumber_ssim: 'this is the call number'
    }
  end

  let(:diff_call_record) do
    {
      id: '333',
      visibility_ssi: 'Public',
      callNumber_ssim: 'this is the call number, but different'
    }
  end

  let(:test_record) do
    {
      id: '111',
      title_tesim: ["Diversity Bull Dogs", "this is the second title"],
      creator_ssim: ['Frederick,  Eric & Maggie'],
      format: 'three dimensional object',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/111',
      language_ssim: ['en', 'eng', 'zz'],
      description_tesim: ["Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.", "here is something else about it"],
      visibility_ssi: 'Public',
      abstract_tesim: "this is an abstract",
      alternativeTitle_tesim: ["this is an alternative title", "this is the second alternative title"],
      genre_ssim: ["this is the genre", "this is the second genre"],
      subjectGeographic_ssim: ['this is the geo subject', 'these are the geo subjects'],
      resourceType_ssim: "this is the resource type",
      subjectName_ssim: ['this is the subject name', 'these are the subject names'],
      subjectTopic_ssim: ['this is the subject topic', 'these are the subject topics'],
      extentOfDigitization_ssim: 'this is the extent of digitization',
      rights_ssim: "these are the rights",
      creationPlace_ssim: "this is the publication place",
      sourceCreated_tesim: "this is the source created",
      publisher_ssim: "this is the publisher",
      copyrightDate_ssim: "this is the copyright date",
      source_ssim: "this is the source",
      recordType_ssi: "this is the record type",
      sourceTitle_tesim: "this is the source title",
      sourceCreator_tesim: "this is the source creator",
      sourceDate_tesim: "this is the source date",
      sourceNote_tesim: "this is the source note",
      preferredCitation_tesim: ["these are the references", "this is the second reference"],
      date_ssim: "this is the date",
      oid_ssi: '2345678',
      callNumber_ssim: 'this is the call number',
      containerGrouping_tesim: 'this is the container information',
      orbisBibId_ssi: '1234567',
      findingAid_ssim: 'this is the finding aid',
      edition_ssim: 'this is the edition',
      material_tesim: "this is the material, using ssim",
      scale_tesim: "this is the scale, using ssim",
      digital_ssim: "this is the digital, using ssim",
      coordinates_ssim: "this is the coordinates, using ssim",
      projection_tesim: "this is the projection, using ssim",
      extent_ssim: ["this is the extent, using ssim", "here is another extent"]
    }
  end

  context 'Within main document' do
    subject(:document) { find(:css, '#document') }
    it 'displays Title in results' do
      expect(page.html).to match("Diversity Bull Dogs<br/>")
      expect(document).to have_content("this is the second title")
    end
    it 'displays Creator in results' do
      expect(document).to have_content("Frederick, Eric & Maggie")
    end
    it 'displays format in results' do
      expect(document).to have_content("three dimensional object")
    end
    it 'displays extent in results' do
      expect(document).to have_content("this is the extent, using ssim")
      # extent should be separated by new line
      expect(page).to have_text("this is the extent, using ssimhere is another extent")
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
    it 'displays language in results' do
      expect(document).to have_content("English (en)")
      expect(document).to have_content("English (eng)")
      expect(document).to have_content("zz")
    end
    it 'displays description in results' do
      expect(document).to have_content("Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.")
      # extent should be separated by new line
      expect(page).to have_text("Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.here is something else about it")
    end
    it 'displays the Abstract in results' do
      expect(document).to have_content("this is an abstract")
    end
    it 'displays the Alternative Title in results' do
      expect(page.html).to match("this is an alternative title<br/>")
      expect(document).to have_content("this is the second alternative title")
    end
    it 'displays the Genre in results' do
      expect(document).to have_content("this is the genre")
    end
    it 'displays the Subject (Geographic) in results' do
      expect(document).to have_content("this is the geo subject")
      expect(document).to have_content("these are the geo subjects")
    end
    it 'displays the Subject (Topic) in results' do
      expect(document).to have_content("this is the subject topic")
      expect(document).to have_content("these are the subject topics")
    end
    it 'displays the Resource Type in results' do
      expect(document).to have_content("this is the resource type")
    end
    it 'displays the Subject (Name) in results' do
      expect(document).to have_content("this is the subject name")
      expect(document).to have_content("these are the subject names")
    end
    it 'displays the Extent of Digitization in results' do
      expect(document).to have_content("this is the extent of digitization")
    end
    it 'displays the Access in results' do
      expect(document).to have_content("Public")
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
    it 'does not display the Record Type in results' do
      expect(document).not_to have_content("this is the record type")
    end
    it 'displays the Source Title in results' do
      expect(document).to have_content("this is the source title")
    end
    it 'displays the Source Date in results' do
      expect(document).to have_content("this is the source date")
    end
    it 'displays the Source Creator in results' do
      expect(document).to have_content("this is the source creator")
    end
    it 'displays the Source Note in results' do
      expect(document).to have_content("this is the source note")
    end
    it 'displays the References in results' do
      expect(page.html).to match("these are the references<br/>")
      expect(document).to have_content("this is the second reference")
    end
    it 'displays the Date in results' do
      expect(document).to have_content("this is the date")
    end
    it 'displays the OID in results' do
      expect(document).to have_content("2345678")
    end

    it 'displays the Container/Volume Information in results' do
      expect(document).to have_content("this is the container information")
    end
    it 'displays the Orbis Bib ID in results' do
      expect(document).to have_content("1234567")
    end
    it 'displays the Finding Aid in results' do
      expect(document).to have_content("this is the finding aid")
    end
    it 'displays the Edition in results' do
      expect(document).to have_content("this is the edition")
    end
    it 'displays the call number in results as link' do
      expect(page).to have_link("this is the call number", href: '/catalog?f%5BcallNumber_ssim%5D%5B%5D=this+is+the+call+number')
      expect(page).not_to have_link("this is the call number", href: '/catalog?f%5BcallNumber_ssim%5D%5B%5D=this+is+the+call+number+but+different')
    end
    it 'contains a link on genre to its facet' do
      expect(page).to have_link('this is the genre', href: '/catalog?f%5Bgenre_ssim%5D%5B%5D=this is the genre')
      expect(page).to have_link('this is the second genre', href: '/catalog?f%5Bgenre_ssim%5D%5B%5D=this is the second genre')

      # ensures that genre is separated with new line rather than concatenated with commas and 'and'
      expect(page).to have_text("this is the genrethis is the second genre")
    end
    it 'contains a link on format to its facet' do
      expect(page).to have_link('three dimensional object', href: '/catalog?f%5Bformat%5D%5B%5D=three+dimensional+object')
    end
    it 'contains a link on resource type to its facet' do
      expect(page).to have_link('this is the resource type', href: '/catalog?f%5BresourceType_ssim%5D%5B%5D=this+is+the+resource+type')
    end
    it 'contains a link on language to its facet' do
      expect(page).to have_link('English (en)', href: '/catalog?f%5Blanguage_ssim%5D%5B%5D=English (en)')
      expect(page).to have_link('English (eng)', href: '/catalog?f%5Blanguage_ssim%5D%5B%5D=English (eng)')
      expect(page).to have_link('zz', href: '/catalog?f%5Blanguage_ssim%5D%5B%5D=zz')
    end
    it 'contains a link on the Orbis Bib ID to the Orbis catalog record' do
      expect(page).to have_link('1234567', href: 'http://hdl.handle.net/10079/bibid/1234567')
    end
    it 'contains a link for the Creator field to the facet' do
      expect(page).to have_link('Frederick, Eric & Maggie', href: '/catalog?f%5Bcreator_ssim%5D%5B%5D=Frederick%2C++Eric+%26+Maggie')
    end
    it 'contains a link on the Finding Aid to the Finding Aid catalog record' do
      expect(page).to have_link('this is the finding aid', href: 'this is the finding aid')
    end
    it 'contains a link on the more info to the more info record' do
      expect(page).to have_link('http://0.0.0.0:3000/catalog/111', href: 'http://0.0.0.0:3000/catalog/111')
    end
    it 'contains a link on subject (topic) to its facet' do
      expect(page).to have_link('this is the subject topic', href: '/catalog?f%5BsubjectTopic_ssim%5D%5B%5D=this is the subject topic')
      expect(page).to have_link('these are the subject topics', href: '/catalog?f%5BsubjectTopic_ssim%5D%5B%5D=these are the subject topics')
    end
    it 'contains a link on subject (name) to its facet' do
      expect(page).to have_link('this is the subject name', href: '/catalog?f%5BsubjectName_ssim%5D%5B%5D=this is the subject name')
      expect(page).to have_link('these are the subject names', href: '/catalog?f%5BsubjectName_ssim%5D%5B%5D=these are the subject names')
    end
    it 'contains a link on subject (geographic) to its facet' do
      expect(page).to have_link('this is the geo subject', href: '/catalog?f%5BsubjectGeographic_ssim%5D%5B%5D=this is the geo subject')
      expect(page).to have_link('these are the geo subjects', href: '/catalog?f%5BsubjectGeographic_ssim%5D%5B%5D=these are the geo subjects')
    end
  end

  it 'has expected css' do
    expect(page).to have_css '.card'
    expect(page).to have_css '.iiif-logo'
    expect(page).to have_css '.list-group'
    expect(page).to have_css '.list-group-item'
    expect(page).to have_css '.single-item-show'
    expect(page).to have_css '.show-tools'
    expect(page).to have_css '.show-header'
    expect(page).to have_css '.universal-viewer-iframe'
  end
end
