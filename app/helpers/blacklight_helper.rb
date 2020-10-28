# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

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
    url = request.url.gsub(/[?&]range%5BdateStructured_ssim%5D%5Bmissing%5D=true&commit=Apply/, '')
    url.gsub!(/[?&]range%5BdateStructured_ssim%5D%5Bmissing%5D=true/, '')
  end

  # removes date range params from link
  def range_remove_url
    url = request.url.gsub(/[&?]range%5BdateStructured_ssim%5D%5Bbegin%5D=[\d]{4}&range%5BdateStructured_ssim%5D%5Bend%5D=[\d]{4}&commit=Apply/, '')
    url.gsub(/[&?]range%5BdateStructured_ssim%5D%5Bbegin%5D=[\d]{4}&range%5BdateStructured_ssim%5D%5Bend%5D=[\d]{4}/, '')
  end

  def manifest_url(oid)
    File.join(manifest_base_url, "#{oid}.json")
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

    language_values = args
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

  def format_field(field, field_name)
    if field_name == 'language_ssim'
      language_codes_as_links(field)
    elsif field_name == 'format'
      field.map do |f|
        link_to f.to_s, ('/?f%5Bformat%5D%5B%5D=' + f.to_s.split.join('+')).to_s
      end[0]
    elsif field_name == 'genre_ssim'
      field.map do |f|
        link_to f.to_s, ('/?f%5Bgenre_ssim%5D%5B%5D=' + f.to_s.split.join('+')).to_s
      end[0]
    elsif field_name == 'resourceType_ssim'
      field.map do |f|
        link_to f.to_s, ('/?f%5BresourceType_ssim%5D%5B%5D=' + f.to_s.split.join('+')).to_s
      end[0]
    elsif field_name == 'findingAid_ssim'
      link_to (field[0]).to_s, (field[0]).to_s
    elsif field_name == 'identifierShelfMark_ssim'
      field.map do |f|
        link_to f.to_s, ('/?f%5BidentifierShelfMark_ssim%5D%5B%5D=' + f.to_s.split.join('+')).to_s
      end[0]
    elsif field_name == 'orbisBibId_ssi'
      link_to field.to_s, "http://hdl.handle.net/10079/bibid/#{field}"
    elsif !field.respond_to?('doc_presenter') && field.respond_to?('to_sentence')
      field.to_sentence
    elsif !field.respond_to?('doc_presenter')
      field.to_s
    else
      doc_presenter.field_value field
    end
  end
end
