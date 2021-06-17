# frozen_string_literal: true
# Build the search query that is passed to solr. This is where we can configure
# the search "processor chain", i.e., anything that should be appended to the
# search. For Yale, we are limiting searches to only records that are marked Public or
# Yale Community Only.
# @example
#      solr_parameters[:fq] << '((visibility_ssi:Public) OR (visibility_ssi:"Yale Community Only"))'
# @example Adding a new step to the processor chain
#   self.default_processor_chain += [:add_custom_data_to_query]
#
#   def add_custom_data_to_query(solr_parameters)
#     solr_parameters[:custom] = blacklight_params[:user_value]
#   end
#
# rubocop:disable Metrics/ClassLength
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder
  include AccessHelper

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr, :setup_field_list]
  # include BlacklightRangeLimit::RangeLimitBuilder

  # Add the `filter_by_visibility` method to the processor chain
  self.default_processor_chain += [:filter_by_visibility]
  self.default_processor_chain += [:highlight_fields]

  #
  # This is list of fields for requests to Solr (the fl parameter)
  #   This list is used in all Solr queries in SearchBuilder and SearchService.fetch to limit which fields are
  #   returned when querying Solr.  It is used so that fulltext_tesim is not returned during queries or fetch.
  #   When a new Solr field is indexed and needed in blacklight, it must be added to this list.
  #   See: https://solr.apache.org/guide/8_0/common-query-parameters.html#fl-field-list-parameter
  def self.solr_record_fields
    %w[
      id
      timestamp
      score
      abstract_tesim
      accessionNumber_ssi
      accessRestrictions_tesim
      alternativeTitle_tesim
      alternativeTitleDisplay_tesim
      archiveSpaceUri_ssi
      box_ssim
      callNumber_ssim
      callNumber_tesim
      caption_tesim
      child_oids_ssim
      collectionId_ssim
      collectionId_tesim
      containerGrouping_ssim
      containerGrouping_tesim
      contents_tesim
      contributor_tsim
      contributorDisplay_tsim
      coordinates_ssim
      copyrightDate_ssim
      creator_ssim
      creator_tesim
      creatorDisplay_tsim
      creationPlace_ssim
      creationPlace_tesim
      date_ssim
      dateDepicted_ssim
      year_isim
      dateStructured_ssim
      dependentUris_ssim
      description_tesim
      digital_ssim
      edition_ssim
      edition_tesim
      extent_ssim
      extentOfDigitization_ssim
      findingAid_ssim
      folder_ssim
      format
      format_tesim
      genre_ssim
      genre_tesim
      geoSubject_ssim
      has_fulltext_ssi
      hashed_id_ssi
      identifierMfhd_ssim
      imageCount_isi
      indexedBy_tsim
      label_tesim
      language_ssim
      languageCode_ssim
      localRecordNumber_ssim
      material_tesim
      number_of_pages_ss
      oid_ssi
      orbisBarcode_ssi
      orbisBibId_ssi
      partOf_tesim
      preferredCitation_tesim
      projection_tesim
      public_bsi
      publisher_tesim
      publisher_ssim
      recordType_ssi
      repository_ssim
      resourceType_ssim
      resourceType_tesim
      rights_ssim
      rights_tesim
      scale_tesim
      source_ssim
      sourceCreated_tesim
      sourceDate_tesim
      sourceEdition_tesim
      sourceNote_tesim
      sourceTitle_tesim
      sourceCreator_tesim
      subjectEra_ssim
      subjectGeographic_ssim
      subjectGeographic_tesim
      subjectTitle_tsim
      subjectTitleDisplay_tsim
      subjectName_ssim
      subjectName_tesim
      subjectTopic_tesim
      subjectTopic_ssim
      thumbnail_path_ss
      title_tesim
      title_ssim
      uri_ssim
      url_suppl_ssim
      viewing_hint_ssi
      visibility_ssi
    ]
  end

  ##
  # Use the solr fq (filter query) parameter to limit search results to only those items
  # which have a visibility_ssi in the set which allow all users to view the metadata.
  # Currently, the ability to view metadata is not affected by the User or IP address.
  # (@see AccessHelper#viewable_metadata_visibilities)
  # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
  def filter_by_visibility(solr_parameters)
    # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1
    solr_parameters[:fq] ||= []
    fq = viewable_metadata_visibilities.map { |visibility| "(visibility_ssi:\"#{visibility}\")" }.join(" OR ")
    solr_parameters[:fq] << "(#{fq})"
  end

  def setup_field_list(solr_parameters)
    solr_parameters[:fl] ||= []
    solr_parameters[:fl] << SearchBuilder.solr_record_fields.map(&:to_s).join(',') if solr_parameters[:fl].empty?
  end

  def highlight_fields(solr_parameters)
    solr_parameters[:hl] ||= []
    solr_parameters['hl.fl'] ||= []

    solr_parameters[:hl] = true
    # solr_parameters['hl.usePhraseHighlighter'] = false
    solr_parameters['hl.requireFieldMatch'] = true
    solr_parameters['hl.preserveMulti'] = true
    solr_parameters['hl.fl'] << "*"
    solr_parameters["hl.simple.pre"] = "<span class='search-highlight'>"
    solr_parameters["hl.simple.post"] = "</span>"
  end
end
# rubocop:enable Metrics/ClassLength
