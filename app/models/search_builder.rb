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
  include BlacklightRangeLimit::RangeLimitBuilder

  # Add the `show_only_public_records` method to the processor chain
  self.default_processor_chain += [:show_only_public_records]
  self.default_processor_chain += [:highlight_fields]

  ##
  # Use the solr fq (filter query) parameter to limit search results to only those items
  # explicitly marked Public or Yale Community Only. This should ensure that only
  # records explicitly cleared for display are ever shown.
  # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
  def show_only_public_records(solr_parameters)
    # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << '((visibility_ssi:Public) OR (visibility_ssi:"Yale Community Only"))'
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
