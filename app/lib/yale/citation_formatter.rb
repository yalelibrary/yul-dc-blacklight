# frozen_string_literal: true
require 'citeproc'
require 'csl/styles'

module Yale
  class CitationFormatter
    include Yale::CitationStringProcessor
    attr_accessor :obj, :default_citations

    # @param obj [SolrDocument], a document from Solr
    def initialize(obj)
      @obj = obj
      @default_citations = {
        "apa": apa_default_citation,
        "modern-language-association": mla_default_citation
      }
    end

    # @param style [String], a string containing a style from the @default_citations hash
    # @return [String], returns the citation for the requested style
    def citation_for(style)
      sanitized_citation(CiteProc::Processor.new(style: style, format: 'html').import(item).render(:bibliography, id: :item).first)
    rescue CiteProc::Error, TypeError, ArgumentError
      @default_citations[style.to_sym]
    end

    private

    # @return [CiteProc::Item],a CiteProc::Item instance containing values from the key_value_* chunks
    def item
      CiteProc::Item.new(key_value_chunk_1.merge(key_value_chunk_2).merge(key_value_chunk_3))
    end

    # @return [Boolean],returns true if creator_ssim has a character that not in any language, else false
    def abnormal_chars?
      obj[:creator_ssim]&.any? { |a| a.match(/[^\p{L}\s]+/) }
    end

    # @return [Hash], a hash with a Solr Document's fields and values as key,value pairs
    # Note: Although in this codebase we are using 'creator', the citation gem expects to receive 'author'
    def key_value_chunk_1
      {
        id: :item,
        abstract: obj[:abstract_tesim]&.join(', '),
        archive_location: obj[:sublocation_tesim]&.join(', '),
        author: obj[:creator_ssim]&.join(', '),
        "call-number": obj[:callNumber_ssim]&.join(', '),
        edition: obj[:edition_tesim]&.join(', '),
        institution: obj[:institution_tesim]&.join(', ')
      }
    end

    # @return [Hash], a hash with a Solr Document's fields and values as key,value pairs
    def key_value_chunk_2
      {
        archive: obj[:holding_repository_tesim]&.join(', '),
        publisher: obj[:publisher_ssim]&.join(', '),
        title: obj[:title_tesim]&.join(', '),
        "collection-title": obj[:member_of_collections_ssim]&.join(', '),
        type: [obj[:format]&.first&.downcase]&.join(', '),
        url: url,
        issued: (obj[:date_ssim] || obj[:year_issued_isim] || obj[:year_created_isim] || [0])&.first&.to_i
      }
    end

    # @return [Hash], a hash with a Solr Document's fields and values as key,value pairs
    def key_value_chunk_3
      {
        dimensions: obj[:extent_ssim]&.join(', '),
        event: obj[:conference_name_tesim]&.join(', '),
        genre: obj[:genre_ssim]&.join(', '),
        ISBN: obj[:isbn_tesim]&.join(', '),
        ISSN: obj[:issn_tesim]&.join(', '),
        keyword: obj[:keywords_tesim]&.join(', '),
        "publisher-place": obj[:creationPlace_ssim]&.join(', ')
      }
    end
  end
end
