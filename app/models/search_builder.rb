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
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include BlacklightAdvancedSearch::AdvancedSearchBuilder
  include BlacklightRangeLimit::RangeLimitBuilder
  include AccessHelper

  self.default_processor_chain += [:add_advanced_parse_q_to_solr, :add_advanced_search_to_solr]
  # include BlacklightRangeLimit::RangeLimitBuilder

  # Add the `filter_by_visibility` method to the processor chain
  self.default_processor_chain += [:filter_by_visibility]
  self.default_processor_chain += [:highlight_fields]

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

  def highlight_fields(solr_parameters)
    solr_parameters[:hl] ||= []
    solr_parameters['hl.fl'] ||= []

    solr_parameters[:hl] = true
    # solr_parameters['hl.usePhraseHighlighter'] = false
    solr_parameters['hl.preserveMulti'] = true
    solr_parameters['hl.fl'] << "*"
    solr_parameters["hl.simple.pre"] = "<span class='search-highlight'>"
    solr_parameters["hl.simple.post"] = "</span>"
  end
end
