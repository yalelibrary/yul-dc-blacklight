# frozen_string_literal: true

module CitationHelper
  # @param document [SolrDocument], the solr document to make a MLA citation for
  # @return [String], The citation as html_safe string
  def mla_citation_txt(document)
    generator = Yale::CitationFormatter.new(document)
    generator.citation_for('modern-language-association')
  end

  # @param document [SolrDocument], the solr document to make a APA citation for
  # @return [String], The citation as html_safe string
  def apa_citation_txt(document)
    generator = Yale::CitationFormatter.new(document)
    generator.citation_for('apa')
  end
end
