# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "View Search Results", type: :system, clean: true, js: false do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record,
              same_call_record,
              diff_call_record,
              no_collection_record])
    solr.commit
    visit '/catalog/111'
  end

  let(:same_call_record) do
    {
      id: '222',
      visibility_ssi: 'Public',
      callNumber_ssim: 'this is the call number',
      source_ssim: 'this is the source'
    }
  end

  let(:diff_call_record) do
    {
      id: '333',
      visibility_ssi: 'Public',
      callNumber_ssim: 'this is the call number, but different'
    }
  end

  let(:no_collection_record) do
    {
      id: '444',
      visibility_ssi: 'Public',
      findingAid_ssim: 'this is the finding aid',
      resourceVersionOnline_ssim: ["this is the online resource that does not display|http://brbl-archive.library.yale.edu"]
    }
  end

  let(:test_record) do
    {
      id: '111',
      title_tesim: ["Diversity Bull Dogs", "this is the second title"],
      creator_ssim: ['Frederick', 'Martin', 'Eric', 'Maggie'],
      collectionCreators_ssim: ['Martin', 'Maggie'],
      format: 'three dimensional object',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/111',
      language_ssim: ['en', 'eng', 'zz'],
      description_tesim: ["Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.", "here is something else about it"],
      visibility_ssi: 'Public',
      digitization_note_tesi: "Digitization note",
      abstract_tesim: ["this is an abstract", "abstract2"],
      alternativeTitle_tesim: ["this is an alternative title", "this is the second alternative title"],
      genre_ssim: ["this is the genre", "this is the second genre"],
      subjectGeographic_ssim: ['this is the geo subject', 'these are the geo subjects'],
      resourceType_ssim: "this is the resource type",
      subjectName_ssim: ['this is the subject name', 'these are the subject names'],
      subjectTopic_ssim: ['this is the subject topic', 'these are the subject topics'],
      extentOfDigitization_ssim: 'this is the extent of digitization',
      rights_ssim: "these are the rights.\nThese are additional rights.",
      creationPlace_ssim: "this is the publication place",
      sourceCreated_tesim: "this is the source created",
      publisher_ssim: "this is the publisher",
      copyrightDate_ssim: "this is the copyright date",
      source_ssim: "aspace",
      repository_ssi: "this is the repository name",
      recordType_ssi: "this is the record type",
      sourceTitle_tesim: "this is the source title",
      sourceCreator_tesim: "this is the source creator",
      sourceDate_tesim: "this is the source date",
      sourceNote_tesim: "this is the source note",
      subjectHeading_ssim: ["Dog > Horse", "Fish"],
      subjectHeadingFacet_ssim: ["Dog", "Dog > Horse", "Fish"],
      preferredCitation_tesim: ["these are the references", "this is the second reference"],
      date_ssim: "this is the date",
      oid_ssi: '2345678',
      callNumber_ssim: 'this is the call number',
      containerGrouping_tesim: 'this is the container information',
      orbisBibId_ssi: '1234567',
      archiveSpaceUri_ssi: "/repositories/11/archival_objects/214638",
      findingAid_ssim: 'this is the finding aid',
      collection_title_ssi: 'this is the collection title',
      edition_ssim: 'this is the edition',
      material_tesim: "this is the material, using ssim",
      scale_tesim: "this is the scale, using ssim",
      digital_ssim: "this is the digital, using ssim",
      coordinates_ssim: "this is the coordinates, using ssim",
      projection_tesim: "this is the projection, using ssim",
      extent_ssim: ["this is the extent, using ssim", "here is another extent"],
      resourceVersionOnline_ssim: ["this is the online resource|http://this/is/the/link"],
      ancestorTitles_tesim: %w[seventh sixth fifth fourth third second first],
      ancestorDisplayStrings_tesim: %w[seventh sixth fifth fourth third second first],
      ancestor_titles_hierarchy_ssim: ['first > ', 'first > second > ', 'first > second > third > ',
                                       'first > second > third > fourth > ', 'first > second > third > fourth > fifth > ',
                                       'first > second > third > fourth > fifth > sixth > ', 'first > second > third > fourth > fifth > sixth > seventh > ']
    }
  end

  context 'Within main document' do
    subject(:document) { find(:css, '#document') }
    it 'displays Title in results' do
      expect(page.html).to match("Diversity Bull Dogs<br/>")
      expect(document).to have_content("this is the second title")
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
      expect(page.html).to match("<p>this is an abstract</p><p>abstract2</p>")
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
    it 'displays the digitization note' do
      expect(document).to have_content("Digitization note")
    end
    it 'displays the Access in results' do
      expect(document).to have_content("Public")
    end
    it 'displays the Rights in results' do
      expect(document).to have_content("these are the rights.These are additional rights.")
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
    it 'displays the Container/Volume in results' do
      expect(document).to have_content("this is the container information")
    end
    it 'displays the Orbis Bib ID in results' do
      expect(document).to have_content("1234567")
    end
    it 'displays the Edition in results' do
      expect(document).to have_content("this is the edition")
    end
    it 'displays the repository name in results' do
      expect(document).to have_content("this is the repository name")
    end
    it 'displays the item location header correctly' do
      expect(document).to have_content("Item Location")
    end
    it 'displays the resource version online' do
      expect(page).to have_link("this is the online resource", href: 'http://this/is/the/link')
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
    it 'contains a link for the Creator field to the facet and displays' do
      expect(page).to have_link('Frederick', href: '/catalog?f%5Bcreator_ssim%5D%5B%5D=Frederick')
      expect(page).to have_link('Eric', href: '/catalog?f%5Bcreator_ssim%5D%5B%5D=Eric')
      expect(page).to have_link('Martin', href: '/catalog?f%5Bcreator_ssim%5D%5B%5D=Martin')
      expect(page).to have_link('Maggie', href: '/catalog?f%5Bcreator_ssim%5D%5B%5D=Maggie')
    end
    it 'contains a link for the From Collection Creator field to the facet and displays' do
      expect(page).to have_content("From the Collection: Maggie")
      expect(page).to have_content("From the Collection: Martin")
      expect(page).not_to have_content("From the Collection: Frederick")
      expect(page).not_to have_content("From the Collection: Eric")
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
    it 'contains a link to Aspace' do
      aspace_link = page.find("a[href = 'https://archives.yale.edu/repositories/11/archival_objects/214638']")

      expect(aspace_link).to be_truthy
      expect(aspace_link).to have_content "View item information in Archives at Yale"
      expect(aspace_link).to have_css("img[src ^= '/assets/YULPopUpWindow']")
    end
    context 'ASpace hierarchy graphical display' do
      it 'has an ellipsis instead of a full tree' do
        expect(page).to have_content "first"
        expect(page).not_to have_text(type: :visible, text: "fourth")
        expect(page).to have_content "..."
        expect(page).to have_content "seventh"
      end
      it 'shows full tree on button click' do
        page.find('.show-full-tree-button').click

        expect(page).to have_content "first"
        expect(page).not_to have_text(type: :visible, text: "...")
        expect(page).to have_content "fourth"
        expect(page).to have_content "seventh"
      end
      it 'has links for each item' do
        within '.aSpace_tree' do
          page.find('.show-full-tree-button').click

          expect(page).to have_link "first"
          expect(page).to have_link "second"
          expect(page).to have_link "third"
          expect(page).to have_link "fourth"
          expect(page).to have_link "fifth"
          expect(page).to have_link "sixth"
          expect(page).to have_link "seventh"
        end
      end
      it 'has title of display item as text' do
        within '.aSpace_tree' do
          page.find('.show-full-tree-button').click

          expect(page).to have_content "Diversity Bull Dogs"
          expect(page).not_to have_link "Diversity Bull Dogs"
        end
      end
      it 'searches on link click' do
        within '.aSpace_tree' do
          page.find('.show-full-tree-button').click

          click_on 'fourth'
        end
        expect(page).to have_content "Diversity Bull Dogs"
      end
      it 'does not preserve search constraints', style: true do
        visit '/catalog?q='
        click_on 'Creator'
        click_on 'Frederick'

        visit '/catalog/111'
        within '.aSpace_tree' do
          page.find('.show-full-tree-button').click

          click_on 'fourth'
        end
        expect(page).to have_css ".filter-name", text: "Found In", count: 1
        expect(page).to have_css ".filter-name", text: "Creator", count: 0
      end
      it 'shows collection information for not ASpace records' do
        visit '/catalog/222'
        expect(page).to have_content "Collection Information"
      end
    end
    context 'ASpace hierarchy breadcrumb' do
      it 'has links for each item' do
        within '.archival-context' do
          expect(page).to have_link "first"
          expect(page).to have_link "second"
          expect(page).to have_link "third"
        end
      end
      it 'searches on link click' do
        within '.archival-context' do
          click_on 'second'
        end
        expect(page).to have_content "Diversity Bull Dogs"
      end
      it 'displays title of current document' do
        within '.archival-context' do
          expect(page).to have_content("Diversity Bull Dogs, this is the second title")
        end
      end
      it 'does not preserves search constraints', style: true do
        visit '/catalog?q='
        click_on 'Creator'
        click_on 'Frederick'

        visit '/catalog/111'
        within '.archival-context' do
          click_on 'second'
        end
        expect(page).to have_css ".filter-name", text: "Collection Title", count: 1
        expect(page).to have_css ".filter-name", text: "Repository", count: 1
        expect(page).to have_css ".filter-name", text: "Creator", count: 0
      end
    end

    it 'contains a link to Finding Aid' do
      finding_aid_link = page.find("a[href = 'this is the finding aid']")

      expect(finding_aid_link).to be_truthy
      expect(finding_aid_link).to have_content "View full finding aid for this is the collection title"
      expect(finding_aid_link).to have_css("img[src ^= '/assets/YULPopUpWindow']")
    end

    it 'contains subject heading links' do
      subject_heading_link = page.find("a[title = 'Dog > Horse']")
      expect(subject_heading_link).to be_truthy
      expect(subject_heading_link).to have_content("Horse")
      expect(subject_heading_link['href']).to eq("/catalog?f%5BsubjectHeadingFacet_ssim%5D%5B%5D=Dog+%3E+Horse")
      subject_heading_link.click
      expect(page).to have_css ".filter-name", text: "Subject Heading", count: 1
      expect(page).to have_css ".filter-value", text: "Dog > Horse", count: 1
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
    expect(page).to have_css '.showpage_no_label_tag'
  end

  context 'when record has no collection title' do
    it 'the finding aid contains fallback text in the link' do
      visit '/catalog/444'
      finding_aid_link = page.find("a[href = 'this is the finding aid']")

      expect(finding_aid_link).to be_truthy
      expect(finding_aid_link).to have_content "View full finding aid for this collection"
      expect(finding_aid_link).to have_css("img[src ^= '/assets/YULPopUpWindow']")
    end
  end

  context 'when record has no resource version online link' do
    it 'does not display online resource version' do
      visit '/catalog/444'
      expect(page).not_to have_link(href: 'http://brbl-archive.library.yale.edu')
    end
  end
end
