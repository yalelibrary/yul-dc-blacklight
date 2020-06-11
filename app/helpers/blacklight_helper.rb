# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def manifest_url(oid)
    File.join(manifest_base_url, "#{oid}.json")
  end

  def manifest_base_url
    ENV.fetch('IIIF_MANIFESTS_BASE_URL', "#{request.protocol}localhost/manifests")
  end

  def language_codes(args)
    language_values = args[:document][args[:field]]
    language_values.map do |language_code|
      language_code_to_english(language_code)
    end.join(', ')
  end

  def language_codes_as_links(args)
    out = []

    language_values = args[:document][args[:field]]
    language_values.map do |language_code|
      converted_code = language_code_to_english(language_code)
      link_text = "/?f%5Blanguage_ssim%5D%5B%5D=#{converted_code}"
      out << link_to(converted_code, link_text)
      out << content_tag(:br)
    end
    safe_join(out)
  end

  def search_field_value_link(args)
    field_value = args[:document][args[:field]]
    link_text = "/?q=#{field_value}&search_field=#{args[:field]}"
    link_to(field_value.join, link_text)
  end

  def language_code(args)
    language_value = args
    language_code_to_english(language_value)
  end

  def link_to_orbis_bib_id(arg)
    bib_id = arg[:document][arg[:field]]
    link = "http://hdl.handle.net/10079/bibid/#{bib_id[0]}"

    link_to(bib_id[0], link)
  end

  def link_to_url(arg)
    link_to(arg[:value][0], arg[:value][0])
  end

  private

    def language_code_to_english(language_code)
      language_name_in_english = ISO_639.find_by_code(language_code)&.english_name
      language_name_in_english.present? ? "#{language_name_in_english} (#{language_code})" : language_code
    end
end
