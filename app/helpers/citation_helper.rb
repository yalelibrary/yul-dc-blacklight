# frozen_string_literal: true
require './lib/yale/citation_formatter.rb'

module CitationHelper
  def mla_citation_txt(document)
    generator = Yale::CitationFormatter.new(document)
    generator.citation_for('modern-language-association')
  end

  def apa_citation_txt(document)
    generator = Yale::CitationFormatter.new(document)
    generator.citation_for('apa')
  end
end