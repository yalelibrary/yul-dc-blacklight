# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def pdf_url(oid)
    File.join(pdf_base_url, "#{oid}.pdf")
  end

  def manifest_url(oid)
    File.join(manifest_base_url, "#{oid}.json")
  end

  def pdf_base_url
    ENV.fetch('PDF_BASE_URL', "#{request.protocol}localhost/pdfs")
  end

  def manifest_base_url
    ENV.fetch('IIIF_MANIFESTS_BASE_URL', "#{request.protocol}localhost/manifests")
  end

  def mirador_url(oid)
    "/mirador/#{oid}"
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
      link = "/?f%5Blanguage_ssim%5D%5B%5D=#{converted_code}"
      out << link_to(converted_code, link)
      out << tag.br
    end
    safe_join(out)
  end

  def link_to_orbis_bib_id(arg)
    bib_id = arg[:document][arg[:field]]
    link = "http://hdl.handle.net/10079/bibid/#{bib_id}"

    link_to(bib_id, link)
  end

  def join_with_br(arg)
    values = arg[:document][arg[:field]]
    safe_join(values, '<br/>'.html_safe)
  end

  def link_to_url(arg)
    link_to(arg[:value][0], arg[:value][0])
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

  def render_thumbnail(document, _options)
    # return placeholder image if not logged in for yale only works
    return image_tag('placeholder_restricted.png') if (document[:visibility_ssi].eql? 'Yale Community Only') && !user_signed_in?
    url = document[:thumbnail_path_ss]
    return image_tag('image_not_found.png') unless image_exists?(url)
    return image_tag(url) if ['Public', 'Yale Community Only'].include? document[:visibility_ssi]
  end

  def pristine_search_state
    Blacklight::SearchState.new(params, blacklight_config)
  end

  private

  def image_exists?(url)
    return false if url.blank?
    begin
      # In local development, this is checked inside the container (iiif_image); however, the external browser
      # needs to be able to resolve it, meaning it needs to be localhost
      url = url.gsub("localhost", "iiif_image")
      url = URI.parse(url)
      http = Net::HTTP.get_response(url)
    rescue
      return false
    end

    http.content_type.include? 'image'
  end

  def language_code_to_english(language_code)
    language_name_in_english = ISO_639.find_by_code(language_code)&.english_name
    language_name_in_english.present? ? "#{language_name_in_english} (#{language_code})" : language_code
  end
end
