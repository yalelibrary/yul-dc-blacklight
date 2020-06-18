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
      link = "/?f%5Blanguage_ssim%5D%5B%5D=#{converted_code}"
      out << link_to(converted_code, link)
      out << tag.br
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

  def render_thumbnail(document, _options)
    # return placeholder image if not logged in for yale only works
    return image_tag('placeholder_restricted.png') if (document[:visibility_ssi].eql? 'Yale Community Only') && !user_signed_in?

    oid = sanitize_oid_ssim(document[:oid_ssim])
    request = get_child_img_url(oid)
    return if request.blank?

    image_tag(request) if ['Public', 'Yale Community Only'].include? document[:visibility_ssi]
  end

  private

  # @return [String], strips anything added to the oid
  # needed for yale-only works which have '-yale' appended to the oid_ssim
  def sanitize_oid_ssim(oid_ssim)
    if (oid = oid_ssim&.first).present?
      oid = oid.match(%r{(?<oid_clean>\d+)}).try(:[], :oid_clean) if oid_ssim.present?
    else
      oid = ''
    end

    oid
  end

  def get_child_img_url(oid)
    return '' if oid.blank?
    begin
      uri = URI("https://collections-test.curationexperts.com/manifests/#{oid}.json")
      json = Net::HTTP.get_response(uri)
      json = Net::HTTP.get_response(URI.parse(json.header['location'])) if json.code.eql? "301"

      result = JSON(json.body)
      request = result['sequences'].first['canvases'].first['images'].first['resource']['service']['@id']

      "#{request}/full/!200,200/0/default.jpg"
    rescue
      ''
    end
  end

  def language_code_to_english(language_code)
    language_name_in_english = ISO_639.find_by_code(language_code)&.english_name
    language_name_in_english.present? ? "#{language_name_in_english} (#{language_code})" : language_code
  end
end
