# frozen_string_literal: true
require 'parsing_nesting/tree'
module BlacklightAdvancedSearch::ParsingNestingParser
  def process_query(_params, config)
    queries = keyword_queries.map do |field, query|
      query = sanitize_quotes(query)
      ParsingNesting::Tree.parse(query, config.advanced_search[:query_parser]).to_query(local_param_hash(field, config))
    end
    queries.join(" #{keyword_op} ")
  end

  # remove double "" and remove all quotes if ANY are unclosed
  def sanitize_quotes(query)
    query.gsub!('""', '"')
    query.delete!('"') if query.count('"').odd?
    query = "" if query.blank?

    query
  end
end
