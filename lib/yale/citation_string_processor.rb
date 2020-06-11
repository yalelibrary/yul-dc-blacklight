# frozen_string_literal: true

module CitationStringProcessor
  def url
    "http://collections-demo.curationexperts.com/catalog/#{obj[:id]}" if obj[:id].present?
  end

  def append_string_with_comma(field)
    "#{field&.first}, " if field.present?
  end

  def append_string_with_period(field)
    "#{field&.first}. " if field.present?
  end

  def apa_edition
    ", #{obj[:edition_tesim].first}" if obj[:edition_tesim].present?
  end

  def apa_box
    " (#{obj[:box_ssim]})" if obj[:box_ssim].present?
  end

  def sanitized_citation(citation)
    if !citation.include?(url) && citation.last != "."
      citation << ". #{url}."
    elsif !citation.include?(url) && citation.last == "."
      citation << " #{url}."
    else
      citation
    end
  end

  def author_name_no_period
    return obj[:author_ssim].map { |a| a.first(a.size - 1) } if obj[:author_ssim]&.any? { |a| a&.split('')&.last == '.' }
    obj[:author_ssim]
  end

  def formatted_apa_author
    return joined_apa_author_names unless abnormal_chars? || obj[:author_ssim].blank?
    "#{author_name_no_period&.join(', & ')}. " unless obj[:author_ssim].blank?
  end

  def formatted_mla_author
    return joined_mla_author_names unless abnormal_chars? || obj[:author_ssim].blank?
    "#{author_name_no_period&.join(', ')}. " unless obj[:author_ssim].blank?
  end

  def apa_default_citation
    [
      formatted_apa_author,
      apa_box,
      ("(#{obj[:date_tsim]&.first})" unless obj[:date_tsim].nil?),
      ("[#{obj[:title_tsim]&.first}#{apa_edition}]. " unless obj[:title_tsim].nil?),
      append_string_with_period(obj[:partOf_ssim]),
      url,
      "."
    ].join('')
  end

  def mla_default_citation
    [
      formatted_mla_author,
      append_string_with_period(obj[:title_tsim]),
      append_string_with_period(obj[:box_ssim]),
      append_string_with_period(obj[:date_tsim]),
      append_string_with_period(obj[:partOf_ssim]),
      url,
      "."
    ].join('')
  end

  def joined_apa_author_names
    "#{obj[:author_ssim].map { |f| f.split(' ').last + ', ' + f.split(' ').first(f.split.size - 1)&.map(&:first)&.join('. ') }&.join(', & ')}. "
  end

  def joined_mla_author_names
    "#{obj[:author_ssim].map { |f| f.split(' ').last + ', ' + f.split(' ').first(f.split.size - 1).join(' ') }&.join(', ')}. "
  end
end
