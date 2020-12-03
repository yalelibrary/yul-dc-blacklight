# frozen_string_literal: true
class CatalogController < ApplicationController
  include BlacklightAdvancedSearch::Controller
  include Blacklight::Catalog
  include Blacklight::Marc::Catalog
  include BlacklightRangeLimit::ControllerOverride

  before_action :determine_per_page

  configure_blacklight do |config|
    # default advanced config values
    config.advanced_search ||= Blacklight::OpenStructWithHashAccess.new
    # config.advanced_search[:qt] ||= 'advanced'
    config.advanced_search[:url_key] ||= 'advanced'
    config.advanced_search[:query_parser] ||= 'edismax'
    config.advanced_search[:form_solr_parameters] ||= {}

    ## Gallery View
    config.view.gallery.partials = [:index_header]
    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)

    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    # config.default_solr_params = {
    #   rows: 10
    # }

    # solr path which will be added to solr base url before the other solr params.
    # config.solr_path = 'select'
    # config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title_tesim'
    # config.index.display_type_field = 'format'
    config.index.thumbnail_method = :render_thumbnail

    # Remove bookmark functionality from the research page
    # config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    # Remove bookmark functionality from the item page
    # config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    # config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    # config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action :ask_library, partial: 'ask_library'
    config.add_nav_action :reserve_rooms, partial: 'reserve_rooms'
    config.add_nav_action :study_places, partial: 'study_places'
    config.show.partials.insert(1, :uv)

    # solr field configuration for document/show views
    # config.show.title_field = 'title_tesim'
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'
    config.show.document_presenter_class = Yul::MetadataPresenter

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'extentOfDigitization_ssim', label: 'Extent of Digitization', limit: true
    config.add_facet_field 'format', label: 'Format', limit: true
    config.add_facet_field 'genre_ssim', label: 'Genre', limit: true
    config.add_facet_field 'resourceType_ssim', label: 'Resource Type', limit: true
    config.add_facet_field 'language_ssim', label: 'Language', limit: true, helper_method: :language_code
    config.add_facet_field 'creator_ssim', label: 'Creator', limit: true
    config.add_facet_field 'subjectTopic_ssim', label: 'Subject (Topic)', limit: true
    config.add_facet_field 'subjectName_ssim', label: 'Subject (Name)', limit: true
    config.add_facet_field 'subject_ssim', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    config.add_facet_field 'publicationPlace_ssim', label: 'Publication Place', limit: true
    config.add_facet_field 'partOf_ssim', label: 'Digital Collection', limit: true
    config.add_facet_field 'pub_date_ssim', label: 'Publication Year', single: true
    config.add_facet_field 'dateStructured_ssim', label: 'Publication Date',
                                                  range: {
                                                    num_segments: 6,
                                                    assumed_boundaries: [800, Time.current.year + 2],
                                                    segments: true,
                                                    maxlength: 4
                                                  }, solr_params: { 'facet.pivot.mincount' => 2 }

    # the facets below are set to false because we aren't filtering on them from the main search page
    # but we need to be able to provide a label when they are filtered upon from an individual show page
    config.add_facet_field 'identifierShelfMark_ssim', label: 'Call Number', show: false

    # This was example code after running rails generate blacklight_range_limit:install
    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', query: {
    #    years_5: { label: 'within 5 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 5} TO *]" },
    #    years_10: { label: 'within 10 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 10} TO *]" },
    #    years_25: { label: 'within 25 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 25} TO *]" }
    # }
    disp_highlight_on_search_params = {
      'hl': true,
      'hl.method': 'original',
      'hl.usePhraseHighlighter': true,
      'hl.preserveMulti': false,
      "hl.simple.pre": "<span class='search-highlight'>",
      "hl.simple.post": "</span>",
      "hl.fragsize": 40
    }
    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'creator_tesim', label: 'Creator', highlight: true
    config.add_index_field 'date_ssim', label: 'Date', highlight: true
    config.add_index_field 'identifierShelfMark_tesim', label: 'Call Number', highlight: true
    config.add_index_field 'imageCount_isi', label: 'Image Count'
    config.add_index_field 'partOf_ssim', label: 'Collection Name'
    config.add_index_field 'resourceType_tesim', label: 'Resource Type', highlight: true
    config.add_index_field 'abstract_tesim', label: 'Abstract', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'alternativeTitle_tesim', label: 'Alternative Title', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'description_tesim', label: 'Description', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'subjectGeographic_tesim', label: 'Subject (Geographic)', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'orbisBidId_ssi', label: 'Orbis BidId', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'publicatonPlace_tesim', label: 'Publication Place', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'publisher_tesim', label: 'Publisher', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'sourceCreated_tesim', label: 'Created Source', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'subjectName_tesim', label: 'Subject (Name)', highlight: true, solr_params: disp_highlight_on_search_params
    config.add_index_field 'subjectTopic_tesim', label: 'Subject (Topic)', highlight: true, solr_params: disp_highlight_on_search_params

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #
    # The following keys decide which group the field is displayed in.
    # For example add 'metadata: 'description'` to add a show field to the description block
    # metadata = [
    #     'description',
    #     'keyword',
    #     'origin',
    #     'identifier',
    #     'usage',
    #     'migration_source'

    # Description Group
    config.add_show_field 'abstract_tesim', label: 'Abstract', metadata: 'description'
    config.add_show_field 'alternativeTitle_tesim', label: 'Alternative Title', metadata: 'description'
    config.add_show_field 'description_tesim', label: 'Description', metadata: 'description'
    config.add_show_field 'extent_ssim', label: 'Extent', metadata: 'description'
    config.add_show_field 'extentOfDigitization_ssim', label: 'Extent of Digitization', metadata: 'description'
    config.add_show_field 'numberOfPages_ssim', label: 'Number of Pages', metadata: 'description'
    config.add_show_field 'references_tesim', label: 'References', metadata: 'description'
    config.add_show_field 'projection_tesim', label: 'Projection', metadata: 'description'
    config.add_show_field 'scale_tesim', label: 'Scale', metadata: 'description'
    config.add_show_field 'subtitle_tesim', label: 'Subtitle', metadata: 'description'
    config.add_show_field 'subtitle_vern_ssim', label: 'Subtitle', metadata: 'description'

    # Keywords Group
    config.add_show_field 'format', label: 'Format', metadata: 'keyword', link_to_facet: true
    config.add_show_field 'genre_ssim', label: 'Genre', metadata: 'keyword', link_to_facet: true, helper_method: :faceted_join_with_br
    config.add_show_field 'geoSubject_ssim', label: 'Subject (Geographic)', metadata: 'keyword', helper_method: :join_with_br
    config.add_show_field 'material_tesim', label: 'Material', metadata: 'keyword'
    config.add_show_field 'resourceType_ssim', label: 'Resource Type', metadata: 'keyword', link_to_facet: true
    config.add_show_field 'subjectName_ssim', label: 'Subject (Name)', metadata: 'keyword', helper_method: :join_with_br
    config.add_show_field 'subjectTopic_tesim', label: 'Subject (Topic)', metadata: 'keyword', helper_method: :join_with_br

    # Origin Group
    config.add_show_field 'creator_ssim', label: 'Creator', metadata: 'origin', link_to_facet: true
    config.add_show_field 'copyrightDate_ssim', label: 'Copyright Date', metadata: 'origin'
    config.add_show_field 'coordinates_ssim', label: 'Coordinates', metadata: 'origin'
    config.add_show_field 'date_ssim', label: 'Date', metadata: 'origin'
    config.add_show_field 'digital_ssim', label: 'Digital', metadata: 'origin'
    config.add_show_field 'edition_ssim', label: 'Edition', metadata: 'origin'
    config.add_show_field 'language_ssim', label: 'Language', metadata: 'origin', helper_method: :language_codes_as_links
    config.add_show_field 'publicationPlace_ssim', label: 'Publication Place', metadata: 'origin'
    config.add_show_field 'publisher_ssim', label: 'Publisher', metadata: 'origin'
    config.add_show_field 'published_ssim', label: 'Published', metadata: 'origin'
    config.add_show_field 'sourceCreated_tesim', label: 'Source Created', metadata: 'origin'
    config.add_show_field 'sourceDate_tesim', label: 'Source Date', metadata: 'origin'
    config.add_show_field 'sourceEdition_tesim', label: 'Source Edition', metadata: 'origin'
    config.add_show_field 'sourceNote_tesim', label: 'Source Note', metadata: 'origin'
    config.add_show_field 'sourceTitle_tesim', label: 'Source Title', metadata: 'origin'

    # Identifiers Group
    config.add_show_field 'containerGrouping_ssim', label: 'Container Grouping', metadata: 'identifier'
    config.add_show_field 'children_ssim', label: 'Children', metadata: 'identifier'
    config.add_show_field 'findingAid_ssim', label: 'Finding Aid', metadata: 'identifier', helper_method: :link_to_url
    config.add_show_field 'folder_ssim', label: 'Folder', metadata: 'identifier'
    config.add_show_field 'identifierMfhd_ssim', label: 'Identifier MFHD', metadata: 'identifier'
    config.add_show_field 'identifierShelfMark_ssim', label: 'Call Number', metadata: 'identifier', link_to_facet: true
    config.add_show_field 'importUrl_ssim', label: 'Import URL', metadata: 'identifier'
    config.add_show_field 'isbn_ssim', label: 'ISBN', metadata: 'identifier'
    config.add_show_field 'orbisBarcode_ssi', label: 'Orbis Bar Code', metadata: 'identifier'
    config.add_show_field 'orbisBibId_ssi', label: 'Orbis Bib ID', metadata: 'identifier', helper_method: :link_to_orbis_bib_id
    config.add_show_field 'oid_ssi', label: 'OID', metadata: 'identifier'
    config.add_show_field 'partOf_ssim', label: 'Collection Name', metadata: 'identifier'
    config.add_show_field 'uri_ssim', label: 'URI', metadata: 'identifier'
    config.add_show_field 'url_fulltext_ssim', label: 'URL', metadata: 'identifier'
    config.add_show_field 'url_suppl_ssim', label: 'More Information', metadata: 'identifier'

    # Usage Group
    config.add_show_field 'rights_ssim', label: 'Rights', metadata: 'usage'

    # Migration Source Group
    config.add_show_field 'recordType_ssi', label: 'Record Type', metadata: 'migration_source'
    config.add_show_field 'source_ssim', label: 'Source', metadata: 'migration_source'

    config.add_field_configuration_to_solr_request!

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # Blacklight 'out of box code'
    # config.add_search_field 'all_fields', label: 'All Fields'

    # Array allows for only listed Solr fields to be searched in the 'Common Fields'
    search_fields = ['abstract_tesim', 'creator_tesim', 'alternativeTitle_tesim', 'description_tesim', 'subjectGeographic_tesim',
                     'identifierShelfMark_tesim', 'orbisBibId_ssi', 'publicatonPlace_tesim', 'publisher_tesim',
                     'resourceType_tesim', 'sourceCreated_tesim', 'subjectName_tesim', 'subjectTopic_tesim',
                     'title_tesim']

    config.add_search_field('all_fields', label: 'Common Fields') do |field|
      field.qt = 'search'
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: search_fields,
        pf: ''
      }
    end

    advanced_search_fields = [
      'abstract_tesim',
      'accessRestrictions_tesim',
      'accessionNumber_ssi',
      'alternativeTitle_tesim',
      'alternativeTitleDisplay_tesim',
      'archiveSpaceUri_ssi',
      'containerGrouping_ssim',
      'collectionId_tesim',
      'contents_tesim',
      'contributor_tsim',
      'contributorDisplay_tsim',
      'coordinates_ssim',
      'creator_tesim',
      'creatorDisplay_tsim',
      'date_ssim',
      'dateStructured_ssim',
      'copyrightDate_ssim',
      'dateDepicted_ssim',
      'description_tesim',
      'digital_ssim',
      'edition_ssim',
      'extent_ssim',
      'extentOfDigitization_ssim',
      'folder_ssim',
      'format_tesim',
      'genre_tesim',
      'identifierMfhd_ssim',
      'identifierShelfMark_tesim',
      'identifierShelfMark_ssim',
      'illustrativeMatter_tesim',
      'caption_tesim',
      'label_tesim',
      'language_ssim',
      'localRecordNumber_ssim',
      'material_tesim',
      'oid_ssi',
      'child_oids_ssim',
      'orbisBarcode_ssi',
      'orbisBibId_ssi',
      'partOf_tesim',
      'projection_tesim',
      'publicationPlace_tesim',
      'publisher_tesim',
      'references_tesim',
      'repository_ssim',
      'resourceType_tesim',
      'rights_tesim',
      'scale_tesim',
      'sourceCreated_tesim',
      'sourceDate_tesim',
      'sourceNote_tesim',
      'sourceTitle_tesim',
      'subjectEra_ssim',
      'subjectGeographic_tesim',
      'subjectTitle_tsim',
      'subjectTitleDisplay_tsim',
      'subjectName_tesim',
      'subjectTopic_tesim',
      'title_tesim',
      'visibility_ssi'
    ]

    config.add_search_field('all_fields_advanced', label: 'All Fields') do |field|
      field.qt = 'search'
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: advanced_search_fields.join(' '),
        pf: ''
      }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    config.add_search_field('creator_tesim', label: 'Creator') do |field|
      field.solr_parameters = {
        qf: 'creator_tesim',
        pf: ''
      }
    end

    config.add_search_field('title_tesim', label: 'Title') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf: 'title_tesim',
        pf: ''
      }
    end

    config.add_search_field('identifierShelfMark_tesim', label: 'Call Number') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf: 'identifierShelfMark_tesim',
        pf: ''
      }
    end

    date_fields = ['date_ssim', 'dateStructured_ssim']

    config.add_search_field('date_fields', label: 'Date') do |field|
      field.qt = 'search'
      field.solr_parameters = {
        qf: date_fields.join(' '),
        pf: ''
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subjectName_ssim', label: 'Subject') do |field|
      field.qt = 'search'
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: '',
        pf: 'subjectName_ssim'
      }
    end

    subject_fields = ['subjectEra_ssim', 'subjectGeographic_tesim', 'subjectTitle_tsim', 'subjectTitleDisplay_tsim', 'subjectName_ssim', 'subjectName_tesim', 'subjectTopic_tesim', 'subjectTopic_ssim']

    config.add_search_field('subject_fields', label: 'Subject') do |field|
      field.qt = 'search'
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: subject_fields.join(' '),
        pf: ''
      }
    end

    genre_fields = ['format_tesim', 'genre_tesim']

    config.add_search_field('genre_fields', label: 'Genre/format') do |field|
      field.qt = 'search'
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: genre_fields.join(' '),
        pf: ''
      }
    end

    config.add_search_field('orbisBibId_ssi', label: 'BibID') do |field|
      field.qt = 'search'
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf: 'orbisBibId_ssi',
        pf: ''
      }
    end

    config.add_search_field('oid_ssi', label: 'OID [Parent/primary]') do |field|
      field.qt = 'search'
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: 'oid_ssi',
        pf: ''
      }
    end

    config.add_search_field('child_oids_ssim', label: 'OID [Child/images]') do |field|
      field.qt = 'search'
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf: 'child_oids_ssim',
        pf: ''
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_si desc, title_si asc', label: 'relevance'
    config.add_sort_field 'creator_ssim asc, title_ssim asc', label: 'Creator (A --> Z)'
    config.add_sort_field 'creator_ssim desc, title_ssim asc', label: 'Creator (Z --> A)'
    config.add_sort_field 'title_ssim asc, oid_ssi desc', label: 'Title (A --> Z)'
    config.add_sort_field 'title_ssim desc, oid_ssi desc', label: 'Title (Z --> A)'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = -1

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = false
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrcongig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end

  def determine_per_page
    grouping = params[:view] == 'gallery' ? [9, 30, 60, 99] : [10, 20, 50, 100]
    blacklight_config[:per_page] = grouping
  end
end
