# frozen_string_literal: true
module Yale
  module CitationStringProcessor
    def url
      "http://collections-demo.curationexperts.com/catalog/#{obj[:id]}" if obj[:id].present?
    end

    def append_string_with_period(field)
      "#{field&.first}. " if field.present?
    end

    def apa_edition
      ", #{obj[:edition_tesim].first}" if obj[:edition_tesim].present?
    end

    def apa_box
      " (#{obj[:containerGrouping_ssim]})" if obj[:containerGrouping_ssim].present?
    end

    def sanitized_citation(citation)
      if !citation.include?(url)
        citation << " #{url}."
      else
        citation
      end
    end

    def creator_name_no_period
      return obj[:creator_ssim].map { |a| a.first(a.size - 1) } if obj[:creator_ssim]&.any? { |a| a&.split('')&.last == '.' }
      obj[:creator_ssim]
    end

    def formatted_apa_creator
      return joined_apa_creator_names unless abnormal_chars? || obj[:creator_ssim].blank?
      "#{creator_name_no_period&.join(', & ')}. " if obj[:creator_ssim].present?
    end

    def formatted_mla_creator
      return joined_mla_creator_names unless abnormal_chars? || obj[:creator_ssim].blank?
      "#{creator_name_no_period&.join(', ')}. " if obj[:creator_ssim].present?
    end

    def apa_default_citation
      [
        formatted_apa_creator,
        apa_box,
        ("(#{obj[:date_ssim]&.first})" unless obj[:date_ssim].nil?),
        ("[#{obj[:title_tesim]&.first}#{apa_edition}]. " unless obj[:title_tesim].nil?),
        append_string_with_period(obj[:partOf_ssim]),
        url,
        "."
      ].join('')
    end

    def mla_default_citation
      [
        formatted_mla_creator,
        append_string_with_period(obj[:title_tesim]),
        append_string_with_period(obj[:containerGrouping_ssim]),
        append_string_with_period(obj[:date_ssim]),
        append_string_with_period(obj[:partOf_ssim]),
        url,
        "."
      ].join('')
    end

    def joined_apa_creator_names
      "#{obj[:creator_ssim].map { |f| f.split(' ').last + ', ' + f.split(' ').first(f.split.size - 1)&.map(&:first)&.join('. ') }&.join(', & ')}. "
    end

    def joined_mla_creator_names
      "#{obj[:creator_ssim].map { |f| f.split(' ').last + ', ' + f.split(' ').first(f.split.size - 1).join(' ') }&.join(', ')}. "
    end
  end
end
