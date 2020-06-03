# frozen_string_literal: true
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:show_only_public_records]

  # @param [Hash] solr_parameters a hash of parameters to be sent to Solr (via RSolr)
  def show_only_public_records(solr_parameters)
    # add a new solr facet query ('fq') parameter that limits results to those with a 'public_b' field of 1
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "visibility_ssi:Public"
  end

  ##
  # @example Adding a new step to the processor chain
  #   self.default_processor_chain += [:add_custom_data_to_query]
  #
  #   def add_custom_data_to_query(solr_parameters)
  #     solr_parameters[:custom] = blacklight_params[:user_value]
  #   end
end
