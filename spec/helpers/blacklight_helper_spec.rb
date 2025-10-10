# frozen_string_literal: true

RSpec.describe BlacklightHelper, helper: true, style: true do
  include Devise::Test::ControllerHelpers
  let(:thumbnail_size) { "!200,200" }

  # used so render_thumbnail can get user info from rspec
  def user_signed_in?
    user.present?
  end

  describe '#fulltext_snippet_separation' do
    let(:document) do
      SolrDocument.new(
      id: 'fulltext',
      visibility_ssi: 'Public',
      fulltext_tesim: ["This is a test.\n\nThis is the OCR <span class='search-highlight'>text</span>", " for 1030368.\n\nSearch for some <span class='search-highlight'>text</span> to see"]
    )
    end

    it 'separates the snippets by line breaks' do
      options = {
        value: ["This is a test.\n\nThis is the OCR <span class='search-highlight'>text</span>", " for 1030368.\n\nSearch for some <span class='search-highlight'>text</span> to see"],
        document: document
      }

      expect(helper.fulltext_snippet_separation(options)).to eq(
        "<p>This is a test.  This is the OCR <span class=\"search-highlight\">text</span><br> for 1030368.  Search for some <span class=\"search-highlight\">text</span> to see</p>"
      )
    end
  end

  describe '#aspace_link' do
    let(:document) { SolrDocument.new(id: 'aspace_link', archiveSpaceUri_ssi: '/repositories/11/archival_objects/21463') }
    let(:args) do
      {
        document: document,
        field: 'archiveSpaceUri_ssi',
        value: '/repositories/11/archival_objects/21463'
      }
    end
    context 'with a valid aspace link' do
      around do |example|
        original_value = ENV["ARCHIVES_SPACE_BASE_URL"]
        ENV["ARCHIVES_SPACE_BASE_URL"] = "http://testaspace.base.url/"
        example.run
        ENV["ARCHIVES_SPACE_BASE_URL"] = original_value
      end
      it 'has a valid aspace link' do
        # rubocop:disable Layout/LineLength
        aspace_test_link = helper.aspace_link(args)
        expect(aspace_test_link).to match "<a target=\"_blank\" rel=\"noopener\" href=\"http://testaspace.base.url/repositories/11/archival_objects/21463\">View item information in Archives at Yale<img id=\"popup_window\" alt=\"pop up window\" src=\"/assets/YULPopUpWindow-1c59edaa31bd75f4397080dd0d8ec793700944190826143cf2db06a08fd09ed4.png\" /></a>"
        # rubocop:enable Layout/LineLength
      end
    end
    context "with out environment variable set" do
      around do |example|
        original_value = ENV["ARCHIVES_SPACE_BASE_URL"]
        ENV["ARCHIVES_SPACE_BASE_URL"] = nil
        example.run
        ENV["ARCHIVES_SPACE_BASE_URL"] = original_value
      end
      it 'has a valid aspace link with default url' do
        # rubocop:disable Layout/LineLength
        aspace_test_link = helper.aspace_link(args)
        expect(aspace_test_link).to match "<a target=\"_blank\" rel=\"noopener\" href=\"https://archives.yale.edu/repositories/11/archival_objects/21463\">View item information in Archives at Yale<img id=\"popup_window\" alt=\"pop up window\" src=\"/assets/YULPopUpWindow-1c59edaa31bd75f4397080dd0d8ec793700944190826143cf2db06a08fd09ed4.png\" /></a>"
        # rubocop:enable Layout/LineLength
      end
    end
  end

  describe '#language_code' do
    context 'with a valid language code' do
      it 'returns the English name of the language' do
        expect(helper.language_code('en')).to eq 'English (en)'
      end
    end

    context 'with an invalid language code' do
      it 'returns the the invalid language code' do
        expect(helper.language_code('zz')).to eq 'zz'
      end
    end
  end

  describe '#language_codes' do
    context 'with a list of language code values' do
      let(:document) { SolrDocument.new(id: 'xyz', language_ssim: ['en', 'eng', 'zz']) }
      let(:args) do
        {
          document: document,
          field: 'language_ssim',
          value: ['en', 'eng', 'zz']
        }
      end

      it 'returns a list of English names of the languages, if available' do
        expect(helper.language_codes(args)).to eq 'English (en), English (eng), zz'
      end
    end
  end

  describe '#join_as_paragraphs' do
    it 'returns multiple items in paragraphs' do
      expect(helper.join_as_paragraphs({ value: %w[Test1 Test2 Test3] })).to eq '<p>Test1</p><p>Test2</p><p>Test3</p>'
    end

    it 'returns one item in paragraph' do
      expect(helper.join_as_paragraphs({ value: %w[Test1] })).to eq '<p>Test1</p>'
    end

    it 'returns nil with nil value' do
      expect(helper.join_as_paragraphs({ value: nil })).to be_nil
    end
  end

  describe 'link to url with label' do
    context 'with a list of links with labels' do
      let(:document) { SolrDocument.new(id: 'xyz') }
      let(:args) do
        {
          document: document,
          field: 'relatedResourceOnline_ssim',
          value: ['View Related Resource|http://library.somewhere.com/special_page', 'http://library.somewhereelse.com/special_page', 'View Related Resource| not']
        }
      end

      it 'returns a list of links with labels' do
        # rubocop:disable Layout/LineLength
        expect(helper.link_to_url_with_label(args)).to eq "<a rel=\"nofollow\" href=\"http://library.somewhere.com/special_page\">View Related Resource</a><br/><a rel=\"nofollow\" href=\"http://library.somewhereelse.com/special_page\">http://library.somewhereelse.com/special_page</a>"
        # rubocop:enable Layout/LineLength
      end
    end
  end

  describe 'link to captions' do
    context 'with several highlights' do
      let(:document) { SolrDocument.new(id: '789', caption_tesim: ['first caption', 'second caption', 'third caption']) }
      let(:args) do
        {
          document: document,
          field: 'caption_tesim',
          config: { Blacklight::Configuration::IndexField => (label = "Caption", highlight = true,
                                                                      solr_params = { hl: true, "hl.method": "original", "hl.requireFieldMatch": true, "hl.usePhraseHighlighter": true, "hl.preserveMulti": false, "hl.simple.pre": "<span class='search-highlight'>", "hl.simple.post": "</span>", "hl.fragsize": 40 }, helper_method = :display_max_caption_characters, key = "caption_tesim", field = "caption_tesim", presenter = Blacklight::FieldPresenter) },
          value: ["first <span class='search-highlight'>caption</span>", "second <span class='search-highlight'>caption</span>", "third <span class='search-highlight'>caption</span>"]
        }
      end
      let(:response) do
          {"responseHeader"=>{"status"=>0, "QTime"=>301, "params"=>{"hl"=>"true", "f.caption_tesim.hl.method"=>"original", "f.alternativeTitle_tesim.hl.simple.post"=>"</span>", "f.alternativeTitle_tesim.hl.usePhraseHighlighter"=>"true", "f.description_tesim.hl.simple.post"=>"</span>", "f.subjectTopic_tesim.hl.preserveMulti"=>"false", "f.caption_tesim.hl.fragsize"=>"40", "f.language_ssim.facet.limit"=>"11", "f.subjectName_tesim.hl.preserveMulti"=>"false", "qf"=>["abstract_tesim", "accessRestrictions_tesim", "accessionNumber_ssi", "alternativeTitle_tesim", "alternativeTitleDisplay_tesim", "ancestorDisplayStrings_tesim", "archiveSpaceUri_ssi", "callNumber_tesim", "containerGrouping_tesim", "collectionId_tesim", "collection_title_ssi", "contents_tesim", "contributor_tsim", "contributorDisplay_tsim", "coordinateDisplay_ssim", "creator_tesim", "creatorDisplay_tsim", "date_ssim", "dateStructured_ssim", "copyrightDate_ssim", "dateDepicted_ssim", "description_tesim", "digital_ssim", "edition_ssim", "extent_ssim", "extentOfDigitization_ssim", "folder_ssim", "format_tesim", "genre_tesim", "identifierMfhd_ssim", "callNumber_ssim", "illustrativeMatter_tesim", "caption_tesim", "label_tesim", "language_ssim", "localRecordNumber_ssim", "material_tesim", "oid_ssi", "child_oids_ssim", "orbisBarcode_ssi", "orbisBibId_ssi", "projection_tesim", "creationPlace_tesim", "publisher_tesim", "preferredCitation_tesim", "project_identifier_tesi", "quicksearchId_ssi", "repository_ssim", "repository_ssi", "resourceType_tesim", "rights_tesim", "scale_tesim", "sourceCreated_tesim", "sourceDate_tesim", "sourceNote_tesim", "sourceTitle_tesim", "subjectEra_ssim", "subjectGeographic_tesim", "subjectTitle_tsim", "subjectTitleDisplay_tsim", "subjectName_tesim", "subjectTopic_tesim", "title_tesim", "visibility_ssi"], "stats"=>"true", "f.orbisBidId_ssi.hl.usePhraseHighlighter"=>"true", "f.abstract_tesim.hl"=>"true", "f.subjectGeographic_tesim.hl.preserveMulti"=>"false", "hl.fl"=>["creator_tesim", "date_ssim", "callNumber_tesim", "sourceTitle_tesim", "resourceType_tesim", "fulltext_tesim", "abstract_tesim", "alternativeTitle_tesim", "description_tesim", "orbisBidId_ssi", "publicatonPlace_tesim", "publisher_tesim", "subjectGeographic_tesim", "subjectName_tesim", "subjectTopic_tesim", "sourceCreated_tesim", "caption_tesim", "*"], "f.caption_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.format.facet.limit"=>"11", "f.subjectTopic_tesim.hl.requireFieldMatch"=>"true", "f.orbisBidId_ssi.hl.method"=>"original", "qt"=>"search", "f.description_tesim.hl.usePhraseHighlighter"=>"true", "f.subjectTopic_tesim.hl.fragsize"=>"40", "f.caption_tesim.hl.usePhraseHighlighter"=>"true", "f.publicatonPlace_tesim.hl"=>"true", "f.caption_tesim.hl.preserveMulti"=>"false", "f.creator_tesim.hl.requireFieldMatch"=>"true", "f.creationPlace_ssim.facet.limit"=>"11", "f.resourceType_tesim.hl.requireFieldMatch"=>"true", "f.resourceType_ssim.facet.limit"=>"11", "f.fulltext_tesim.hl.usePhraseHighlighter"=>"true", "f.abstract_tesim.hl.requireFieldMatch"=>"true", "f.publicatonPlace_tesim.hl.simple.post"=>"</span>", "f.publisher_tesim.hl.requireFieldMatch"=>"true", "f.series_sort_ssi.facet.limit"=>"11", "f.visibility_ssi.facet.limit"=>"11", "f.publisher_tesim.hl.preserveMulti"=>"false", "f.abstract_tesim.hl.preserveMulti"=>"false", "f.sourceCreated_tesim.hl.usePhraseHighlighter"=>"true", "f.publicatonPlace_tesim.hl.usePhraseHighlighter"=>"true", "f.description_tesim.hl.preserveMulti"=>"false", "f.publisher_tesim.hl.fragsize"=>"40", "f.description_tesim.hl"=>"true", "f.callNumber_tesim.hl.requireFieldMatch"=>"true", "f.caption_tesim.hl"=>"true", "f.fulltext_tesim.hl.simple.post"=>"</span>", "hl.requireFieldMatch"=>"true", "f.has_fulltext_ssi.facet.limit"=>"11", "f.creator_ssim.facet.limit"=>"11", "f.subjectGeographic_tesim.hl.fragsize"=>"40", "hl.simple.pre"=>"<span class='search-highlight'>", "f.publicatonPlace_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.orbisBidId_ssi.hl.preserveMulti"=>"false", "f.subjectTopic_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.description_tesim.hl.fragsize"=>"40", "stats.field"=>"year_isim", "f.alternativeTitle_tesim.hl.method"=>"original", "f.subjectGeographic_tesim.hl.requireFieldMatch"=>"true", "hl.preserveMulti"=>"true", "f.subjectName_tesim.hl"=>"true", "f.subjectGeographic_tesim.hl.simple.post"=>"</span>", "f.publicatonPlace_tesim.hl.requireFieldMatch"=>"true", "f.fulltext_tesim.hl.snippets"=>"4", "f.sourceCreated_tesim.hl.method"=>"original", "f.fulltext_tesim.hl.fragsize"=>"40", "f.publicatonPlace_tesim.hl.method"=>"original", "f.subjectName_tesim.hl.fragsize"=>"40", "f.orbisBidId_ssi.hl.fragsize"=>"40", "q"=>"university", "hl.simple.post"=>"</span>", "f.sourceCreated_tesim.hl"=>"true", "f.publisher_tesim.hl.simple.post"=>"</span>", "facet"=>"true", "f.description_tesim.hl.requireFieldMatch"=>"true", "f.sourceCreated_tesim.hl.preserveMulti"=>"false", "f.caption_tesim.hl.simple.post"=>"</span>", "f.publisher_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.fulltext_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.subjectTopic_ssim.facet.limit"=>"11", "f.extentOfDigitization_ssim.facet.limit"=>"11", "f.subject_ssim.facet.limit"=>"21", "f.alternativeTitle_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.fulltext_tesim.hl.requireFieldMatch"=>"true", "f.subjectTopic_tesim.hl.simple.post"=>"</span>", "f.sourceCreated_tesim.hl.requireFieldMatch"=>"true", "f.repository_ssi.facet.limit"=>"11", "f.publisher_tesim.hl.method"=>"original", "f.subjectName_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.sourceCreated_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "sort"=>"score desc, pub_date_si desc, title_ssim asc, archivalSort_ssi asc", "f.description_tesim.hl.method"=>"original", "f.publisher_tesim.hl.usePhraseHighlighter"=>"true", "f.subjectGeographic_tesim.hl"=>"true", "f.sourceCreated_tesim.hl.simple.post"=>"</span>", "f.publicatonPlace_tesim.hl.fragsize"=>"40", "f.subjectName_tesim.hl.simple.post"=>"</span>", "f.genre_ssim.facet.limit"=>"11", "f.series_sort_ssi.facet.sort"=>"index", "f.fulltext_tesim.hl"=>"true", "f.orbisBidId_ssi.hl.simple.pre"=>"<span class='search-highlight'>", "f.alternativeTitle_tesim.hl.preserveMulti"=>"false", "f.subjectName_tesim.hl.usePhraseHighlighter"=>"true", "f.sourceCreated_tesim.hl.fragsize"=>"40", "f.description_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.subjectName_tesim.hl.requireFieldMatch"=>"true", "f.abstract_tesim.hl.fragsize"=>"40", "fl"=>"creator_tesim date_ssim callNumber_tesim sourceTitle_tesim containerGrouping_tesim imageCount_isi resourceType_tesim abstract_tesim alternativeTitle_tesim description_tesim orbisBidId_ssi publicatonPlace_tesim publisher_tesim subjectGeographic_tesim subjectName_tesim subjectTopic_tesim sourceCreated_tesim ancestorTitles_tesim caption_tesim title_tesim creator_ssim contributor_tsim copyrightDate_ssim creationPlace_ssim publisher_ssim provenanceUncontrolled_tesi extent_ssim extentOfDigitization_ssim digitization_note_tesi digitization_funding_source_tesi projection_tesim scale_tesim coordinateDisplay_ssim digital_ssim edition_ssim language_ssim repository_ssi callNumber_ssim sourceCreator_tesim sourceDate_tesim sourceNote_tesim sourceEdition_tesim relatedResourceOnline_ssim resourceVersionOnline_ssim ancestorDisplayStrings_tesim archiveSpaceUri_ssi findingAid_ssim format genre_ssim material_tesim resourceType_ssim subjectGeographic_ssim subjectName_ssim subjectTopic_ssim subjectHeading_ssim visibility_ssi redirect_to_tesi rights_ssim preferredCitation_tesim orbisBibId_ssi mmsId_ssi quicksearchId_ssi oid_ssi url_suppl_ssim collection_title_ssi series_sort_ssi subject_ssim pub_date_ssim year_isim ancestor_titles_hierarchy_ssim subjectHeadingFacet_ssim project_identifier_tesi child_oids_ssim has_fulltext_ssi parent_ssi id timestamp score box_ssim collectionCreators_ssim collectionId_ssim containerGrouping_ssim dependentUris_ssim edition_tesim geoSubject_ssim hashed_id_ssi indexedBy_tsim languageCode_ssim number_of_pages_ss partOf_tesim public_bsi recordType_ssi sensitive_materials_ssi series_ssi source_ssim thumbnail_path_ss title_ssim uri_ssim viewing_hint_ssi abstract_tesim accessRestrictions_tesim accessionNumber_ssi alternativeTitle_tesim alternativeTitleDisplay_tesim ancestorDisplayStrings_tesim archiveSpaceUri_ssi callNumber_tesim containerGrouping_tesim collectionId_tesim collection_title_ssi contents_tesim contributor_tsim contributorDisplay_tsim coordinateDisplay_ssim creator_tesim creatorDisplay_tsim date_ssim dateStructured_ssim copyrightDate_ssim dateDepicted_ssim description_tesim digital_ssim edition_ssim extent_ssim extentOfDigitization_ssim folder_ssim format_tesim genre_tesim identifierMfhd_ssim callNumber_tesim callNumber_ssim illustrativeMatter_tesim caption_tesim label_tesim language_ssim localRecordNumber_ssim material_tesim oid_ssi child_oids_ssim orbisBarcode_ssi orbisBibId_ssi projection_tesim creationPlace_tesim publisher_tesim preferredCitation_tesim project_identifier_tesi quicksearchId_ssi repository_ssim repository_ssi resourceType_tesim rights_tesim scale_tesim sourceCreated_tesim sourceDate_tesim sourceNote_tesim sourceTitle_tesim subjectEra_ssim subjectGeographic_tesim subjectTitle_tsim subjectTitleDisplay_tsim subjectName_tesim subjectTopic_tesim title_tesim visibility_ssi abstract_tesim accessRestrictions_tesim accessionNumber_ssi alternativeTitle_tesim alternativeTitleDisplay_tesim ancestorDisplayStrings_tesim archiveSpaceUri_ssi callNumber_tesim containerGrouping_tesim collectionId_tesim collection_title_ssi contents_tesim contributor_tsim contributorDisplay_tsim coordinateDisplay_ssim creator_tesim creatorDisplay_tsim date_ssim dateStructured_ssim copyrightDate_ssim dateDepicted_ssim description_tesim digital_ssim edition_ssim extent_ssim extentOfDigitization_ssim folder_ssim format_tesim genre_tesim identifierMfhd_ssim callNumber_tesim callNumber_ssim illustrativeMatter_tesim caption_tesim label_tesim language_ssim localRecordNumber_ssim material_tesim oid_ssi child_oids_ssim orbisBarcode_ssi orbisBibId_ssi projection_tesim creationPlace_tesim publisher_tesim preferredCitation_tesim project_identifier_tesi quicksearchId_ssi repository_ssim repository_ssi resourceType_tesim rights_tesim scale_tesim sourceCreated_tesim sourceDate_tesim sourceNote_tesim sourceTitle_tesim subjectEra_ssim subjectGeographic_tesim subjectTitle_tsim subjectTitleDisplay_tsim subjectName_tesim subjectTopic_tesim title_tesim visibility_ssi date_ssim dateStructured_ssim subjectEra_ssim subjectGeographic_tesim subjectTitle_tsim subjectTitleDisplay_tsim subjectName_ssim subjectName_tesim subjectTopic_tesim subjectTopic_ssim format_tesim genre_tesim orbisBibId_ssi quicksearchId_ssi", "f.abstract_tesim.hl.method"=>"original", "f.publisher_tesim.hl"=>"true", "fq"=>"((visibility_ssi:\"Public\") OR (visibility_ssi:\"Yale Community Only\") OR (visibility_ssi:\"Open with Permission\"))", "f.alternativeTitle_tesim.hl.fragsize"=>"40", "f.subjectTopic_tesim.hl.usePhraseHighlighter"=>"true", "defType"=>"edismax", "f.subjectName_tesim.hl.method"=>"original", "f.abstract_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.subjectGeographic_tesim.hl.method"=>"original", "f.subjectGeographic_tesim.hl.usePhraseHighlighter"=>"true", "f.fulltext_tesim.hl.method"=>"original", "wt"=>"json", "facet.field"=>["extentOfDigitization_ssim", "visibility_ssi", "repository_ssi", "collection_title_ssi", "series_sort_ssi", "format", "genre_ssim", "resourceType_ssim", "language_ssim", "creator_ssim", "subjectTopic_ssim", "subjectName_ssim", "subject_ssim", "creationPlace_ssim", "{!ex=pub_date_ssim_single}pub_date_ssim", "year_isim", "callNumber_ssim", "ancestor_titles_hierarchy_ssim", "subjectGeographic_ssim", "subjectHeadingFacet_ssim", "project_identifier_tesi", "child_oids_ssim", "has_fulltext_ssi", "parent_ssi"], "f.sourceTitle_tesim.hl.requireFieldMatch"=>"true", "f.publicatonPlace_tesim.hl.preserveMulti"=>"false", "f.abstract_tesim.hl.simple.post"=>"</span>", "f.subjectTopic_tesim.hl.method"=>"original", "f.orbisBidId_ssi.hl"=>"true", "rows"=>"10", "f.date_ssim.hl.requireFieldMatch"=>"true", "f.orbisBidId_ssi.hl.requireFieldMatch"=>"true", "f.subjectTopic_tesim.hl"=>"true", "f.collection_title_ssi.facet.limit"=>"11", "f.subjectName_ssim.facet.limit"=>"11", "f.alternativeTitle_tesim.hl.requireFieldMatch"=>"true", "f.caption_tesim.hl.requireFieldMatch"=>"true", "f.subjectGeographic_tesim.hl.simple.pre"=>"<span class='search-highlight'>", "f.orbisBidId_ssi.hl.simple.post"=>"</span>", "f.abstract_tesim.hl.usePhraseHighlighter"=>"true", "f.fulltext_tesim.hl.preserveMulti"=>"false", "f.alternativeTitle_tesim.hl"=>"true"}}, "response"=>{"numFound"=>1, "start"=>0, "maxScore"=>0.13076457, "numFoundExact"=>true, "docs"=>[{"id"=>"111", "title_tesim"=>["Jack or Dan the Bulldog"], "creator_tesim"=>["Me and You"], "abstract_tesim"=>["Binding: white with gold embossing."], "alternativeTitle_tesim"=>["The Yale Bulldogs"], "caption_tesim"=>["university mascot"], "description_tesim"=>["in black ink on thin white paper"], "format"=>["three dimensional object"], "callNumber_tesim"=>["Osborn Music MS 4"], "language_ssim"=>["en", "eng", "zz"], "publisher_tesim"=>["Printed for Eric"], "resourceType_tesim"=>["Music (Printed & Manuscript)"], "sourceCreated_tesim"=>["The Whale"], "subjectGeographic_tesim"=>["United States--Maps, Manuscript"], "subjectTopic_tesim"=>["Phrenology--United States"], "subjectName_tesim"=>["Price, Leo"], "visibility_ssi"=>"Public", "timestamp"=>"2025-10-06T17:50:32.363Z", "score"=>0.13076457}]}, "facet_counts"=>{"facet_queries"=>{}, "facet_fields"=>{"extentOfDigitization_ssim"=>[], "visibility_ssi"=>["Public", 1], "repository_ssi"=>[], "collection_title_ssi"=>[], "series_sort_ssi"=>[], "format"=>["three dimensional object", 1], "genre_ssim"=>[], "resourceType_ssim"=>[], "language_ssim"=>["en", 1, "eng", 1, "zz", 1], "creator_ssim"=>[], "subjectTopic_ssim"=>[], "subjectName_ssim"=>[], "subject_ssim"=>[], "creationPlace_ssim"=>[], "pub_date_ssim"=>[], "year_isim"=>[], "callNumber_ssim"=>[], "ancestor_titles_hierarchy_ssim"=>[], "subjectGeographic_ssim"=>[], "subjectHeadingFacet_ssim"=>[], "project_identifier_tesi"=>[], "child_oids_ssim"=>[], "has_fulltext_ssi"=>[], "parent_ssi"=>[]}, "facet_ranges"=>{}, "facet_intervals"=>{}, "facet_heatmaps"=>{}}, "highlighting"=>{"111"=>{"creator_tesim"=>["Me and You"], "callNumber_tesim"=>["Osborn Music MS 4"], "resourceType_tesim"=>["Music (Printed & Manuscript)"], "caption_tesim"=>["<span class='search-highlight'>university</span> mascot"], "id"=>["111"], "visibility_ssi"=>["Public"], "title_tesim"=>["Jack or Dan the Bulldog"], "format"=>["three dimensional object"], "published_ssim"=>["1997"], "language_ssim"=>["en", "eng", "zz"]}}, "stats"=>{"stats_fields"=>{"year_isim"=>{"min"=>nil, "max"=>nil, "count"=>0, "missing"=>1, "sum"=>0.0, "sumOfSquares"=>0.0, "mean"=>"NaN", "stddev"=>0.0}}}, "spellcheck"=>{"suggestions"=>[], "correctlySpelled"=>true}}             
      end

      it 'returns a list of captions with links to the correct child images' do
        allow_any_instance_of(SolrDocument).to_receive(:highlight_field).and_return(response)
        allow_any_instance_of(SolrDocument).to_receive(:has_highlight_field?).and_return(response)
        expect(helper.display_max_caption_characters(args)).to eq "<a rel=\"nofollow\" href=\"/catalog/#{document.id}?child_oid=31234\">first caption</a>, <a rel=\"nofollow\" href=\"/catalog/#{document.id}?child_oid=31235\">second caption</a>, <a rel=\"nofollow\" href=\"/catalog/#{document.id}?child_oid=31236\">third caption</a>"
      end
    end
  end

  describe '#render_thumbnail' do
    context 'with a sensitive materials record' do
      let(:sensitive_materials_document) do
        SolrDocument.new(id: 'test',
                         visibility_ssi: 'Public',
                         sensitive_materials_ssi: 'Yes',
                         oid_ssi: ['2055095'],
                         thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
      end
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end

      it 'returns placeholder with alt text for sensitive materials object' do
        placeholder_image = "/assets/access-image-v2-"
        alt_text = "Access Available within Digital Collections"
        expect(helper.render_thumbnail(sensitive_materials_document, {})).to include(alt_text, placeholder_image)
        expect(helper.render_thumbnail(sensitive_materials_document,
{})).to match("<img alt=\"Access Available within Digital Collections\" src=\"/assets/access-image-v2-f946f99ee0c358bbe16cf8223372b6091680dc48b5082b591eabafdbd7eeb8bd.png\" />")
      end
    end
    context 'with public record and oid with images' do
      let(:valid_document) do
        SolrDocument.new(id: 'test',
                         visibility_ssi: 'Public',
                         oid_ssi: ['2055095'],
                         thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
      end
      let(:non_valid_document) { SolrDocument.new(id: 'test', visibility_ssi: 'Public', oid_ssi: ['9999999999999999']) }
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end
      it 'returns an image_tag for oids that have images' do
        expect(helper.render_thumbnail(valid_document, { alt: "" })).to match "<img [^>]* src=\"http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg\" />"
      end
      it 'returns an image_tag pointing to image_not_found.png for oids without images' do
        expect(helper.render_thumbnail(non_valid_document, {})).to include("<img src=\"/assets/image_not_found-")
      end
    end

    context 'with Yale only records' do
      let(:yale_only_document) do
        SolrDocument.new(
          id: 'test',
          visibility_ssi: 'Yale Community Only',
          oid_ssi: ['2055095'],
          thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg"
        )
      end
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end

      it 'returns placeholder with alt text when logged out' do
        placeholder_image = "/assets/placeholder_restricted-"
        alt_text = "Access Available on YALE network only due to copyright or other restrictions. OFF-SITE? Log in with NetID"
        expect(helper.render_thumbnail(yale_only_document, {})).to include(alt_text, placeholder_image)
      end

      it 'returns image when logged in with valid netid' do
        user = FactoryBot.create(:user, netid: 'net_id')
        sign_in(user) # sign_in so user_signed_in? works in method

        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img [^>]* src=\"http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg\" />")
      end

      # rubocop:disable Layout/LineLength
      it 'user cannot access YCO without a netid' do
        user = FactoryBot.create(:user, netid: nil)
        sign_in(user)
        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img alt=\"Access Available on YALE network only due to copyright or other restrictions. OFF-SITE? Log in with NetID\" src=\"/assets/placeholder_restricted-4d0037c54ed3900f4feaf705e801f4c980164e45ee556f60065c39b4bd4af345.png\" />")
      end
      # rubocop:enable Layout/LineLength

      it 'has lazy loading for the thumbnail image' do
        user = FactoryBot.create(:user, netid: 'net_id')
        sign_in(user)

        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img[^>]* loading=\"lazy\"")
      end

      describe '#range_unknown_remove_url' do
        let(:missing_url) { "/catalog?range%5Byear_isim%5D%5Bmissing%5D=true&search_field=all_fields" }
        let(:clean_url) { %r{catalog[?&]search_field=all_fields} }

        it 'filters out missing when x is clicked' do
          expect(helper.range_unknown_remove_url(missing_url)).to match clean_url
        end
      end

      describe '#range_remove_url' do
        let(:date_facet_url) { "/catalog?search_field=all_fields&range%5Byear_isim%5D%5Bbegin%5D=1116&range%5Byear_isim%5D%5Bend%5D=2002&commit=Apply" }
        let(:clean_url) { %r{catalog[?&]search_field=all_fields} }

        it 'filters out date range when x is clicked' do
          expect(helper.range_remove_url(date_facet_url)).to match clean_url
        end
      end

      describe '#get_date_constraint_params' do
        let(:missing_url) { "/catalog?range%5Byear_isim%5D%5Bmissing%5D=true&search_field=all_fields" }
        let(:date_facet_url) { "/catalog?search_field=all_fields&range%5Byear_isim%5D%5Bbegin%5D=1116&range%5Byear_isim%5D%5Bend%5D=2002&commit=Apply" }
        let(:clean_url) { %r{catalog[?&]search_field=all_fields} }

        context 'with missing date facet applied' do
          let(:params) do
            params = Hash.new { |h, k| h[k] = h.dup.clear }
            params["range"]["year_isim"]["missing"] = true
            params
          end
          it 'assigns the correct values to options' do
            value, label, options = helper.get_date_constraint_params(params, missing_url)
            expect(value).to eq "Unknown"
            expect(label).to eq "Date"
            expect(options[:classes]).to match ["year_isim"]
            expect(options[:remove]).to match clean_url
          end
        end
        context 'with a date range facet applied' do
          let(:params) do
            params = Hash.new { |h, k| h[k] = h.dup.clear }
            params["range"]["year_isim"]["missing"] = false
            params["range"] = Object.new
            params["range"].define_singleton_method(:values) do
              @values ||= [Hash.new { |h, k| h[k] = h.dup.clear }]
              @values
            end
            params["range"].values[0]["begin"] = 1500
            params["range"].values[0]["end"] = 2000
            params
          end
          it 'assigns the correct values to options' do
            value, label, options = helper.get_date_constraint_params(params, date_facet_url)
            expect(value).to eq "1500 - 2000"
            expect(label).to eq "Date"
            expect(options[:classes]).to match ["year_isim"]
            expect(options[:remove]).to match clean_url
          end
        end
      end
    end
  end
end
