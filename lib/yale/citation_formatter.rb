require 'citeproc'
require 'csl/styles'
require './lib/yale/citation_string_processor.rb'

module Yale
  class CitationFormatter
    include CitationStringProcessor
    attr_accessor :obj, :default_citations

    def initialize(obj)
      @obj = obj
      @default_citations = {
          "apa": apa_default_citation,
          "modern-language-association": mla_default_citation
      }
    end

    def citation_for(style)
      sanitized_citation(CiteProc::Processor.new(style: style, format: 'html').import(item).render(:bibliography, id: :item).first)
    rescue CiteProc::Error, TypeError, ArgumentError
      @default_citations[style.to_sym]
    end

    private

    def item
      CiteProc::Item.new(key_value_chunk_1.merge(key_value_chunk_2).merge(key_value_chunk_3))
    end

    def mla_url_test
      [
          obj[:partOf_ssim],
          obj[:edition_tesim],
          obj[:publisher_ssim],
          obj[:date_tsim]
      ].any?(&:present?)
    end

    def abnormal_chars?
      obj[:author_ssim]&.any? { |a| a.match(/[^\p{L}\s]+/) }
    end

    def key_value_chunk_1
      {
          id: :item,
          abstract: obj[:abstract_ssim]&.join(', '),
          archive_location: obj[:sublocation_tesim]&.join(', '),
          author: obj[:author_ssim]&.join(', '),
          "call-number": obj[:identifierShelfMark_ssim]&.join(', '),
          edition: obj[:edition_tesim]&.join(', '),
          institution: obj[:institution_tesim]&.join(', ')
      }
    end

    def key_value_chunk_2
      {
          archive: obj[:holding_repository_tesim]&.join(', '),
          publisher: obj[:publisher_ssim]&.join(', '),
          title: obj[:title_tsim]&.join(', '),
          "collection-title": obj[:member_of_collections_ssim]&.join(', '),
          type: [obj[:format]&.first&.downcase]&.join(', '),
          url: url,
          issued: (obj[:date_tsim] || obj[:year_issued_isim] || obj[:year_created_isim] || [0])&.first&.to_i
      }
    end

    def key_value_chunk_3
      {
          dimensions: obj[:extent_ssim]&.join(', '),
          event: obj[:conference_name_tesim]&.join(', '),
          genre: obj[:genre_ssim]&.join(', '),
          ISBN: obj[:isbn_tesim]&.join(', '),
          ISSN: obj[:issn_tesim]&.join(', '),
          keyword: obj[:keywords_tesim]&.join(', '),
          "publisher-place": obj[:publicationPlace_ssim]&.join(', ')
      }
    end
  end
end