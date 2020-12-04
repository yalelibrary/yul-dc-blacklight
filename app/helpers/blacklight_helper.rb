# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def mirador_url(oid)
    "/mirador/#{oid}"
  end

  # sets up date params for constraint partial
  def render_date_constraint(params)
    label = "Date"

    # if date is unknown
    if params["range"].try(:[], "dateStructured_ssim").try(:[], "missing")
      value = "Unknown"
      remove_url = range_unknown_remove_url
    else
      beg_date = params["range"].values[0]["begin"]
      end_date = params["range"].values[0]["end"]

      value ||= "#{beg_date} - #{end_date}"
      remove_url = range_remove_url
    end

    options = {
      remove: remove_url,
      classes: ["dateStructured_ssim"]
    }
    render partial: "constraints_element", locals: { value: value, label: label, options: options }
  end

  # removes date range params from link with unknown date
  def range_unknown_remove_url
    url = request.url.gsub(/[?&]range%5BdateStructured_.*%5D%5Bmissing%5D=true&commit=Apply/, '')
    url.gsub!(/[?&]range%5BdateStructured_.*%5D%5Bmissing%5D=true/, '')
  end

  # removes date range params from link
  def range_remove_url
    url = request.url.gsub(/[&?]range%5BdateStructured_.*%5D%5Bbegin%5D=[\d]{3,4}&range%5BdateStructured_.*%5D%5Bend%5D=[\d]{3,4}&commit=Apply/, '')
    url.gsub(/[&?]range%5BdateStructured_.*%5D%5Bbegin%5D=[\d]{3,4}&range%5BdateStructured_.*5D%5Bend%5D=[\d]{3,4}/, '')
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
      link = "/catalog?f%5Blanguage_ssim%5D%5B%5D=#{converted_code}"
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

  def faceted_join_with_br(arg)
    values = arg[:document][arg[:field]]
    links = []
    values.each do |value|
      links << link_to(value, build_escaped_facet(arg[:field], value))
    end
    safe_join(links, '<br/>'.html_safe)
  end

  def build_escaped_facet(field, value)
    "/catalog?f" + ERB::Util.url_encode("[#{field}][]") + "=#{value}"
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
    if ['Public', 'Yale Community Only'].include?(document[:visibility_ssi]) && url.present?
      error_image_url = image_url('image_not_found.png')
      return image_tag(url, onerror: "this.error=null;this.src='#{error_image_url}'")
    end
    image_tag('image_not_found.png')
  end

  def pristine_search_state
    Blacklight::SearchState.new(params, blacklight_config)
  end

  private

  def language_code_to_english(language_code)
    language_name_in_english = ISO_639.find_by_code(language_code)&.english_name
    language_name_in_english.present? ? "#{language_name_in_english} (#{language_code})" : language_code
  end
end
