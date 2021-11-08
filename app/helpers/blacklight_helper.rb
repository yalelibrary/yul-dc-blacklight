# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def mirador_url(oid)
    "/mirador/#{oid}"
  end

  # sets up date params for constraint partial
  def get_date_constraint_params(params, url)
    label = "Date"

    # if date is unknown
    if params["range"].try(:[], "year_isim").try(:[], "missing")
      value = "Unknown"
      remove_url = range_unknown_remove_url(url)
    else
      beg_date = params["range"].values[0]["begin"]
      end_date = params["range"].values[0]["end"]

      value ||= "#{beg_date} - #{end_date}"
      remove_url = range_remove_url(url)
    end

    options = {
      remove: remove_url,
      classes: ["year_isim"]
    }
    [value, label, options]
  end

  # removes date range params from link with unknown date
  def range_unknown_remove_url(url_in)
    url = url_in.gsub(/[?&]range%5Byear_.*%5D%5Bmissing%5D=true/, '')
    url.gsub!("&commit=Apply", '')
    url.gsub(/[?&]range%5Byear_.*%5D%5Bmissing%5D=true/, '')
  end

  # removes date range params from link
  def range_remove_url(url_in)
    url = url_in.gsub(/[&?]range%5Byear_.*%5D%5Bbegin%5D=[\d]{3,4}&range%5Byear_.*%5D%5Bend%5D=[\d]{3,4}/, '')
    url.gsub!("&commit=Apply", '')
    url.gsub(/[&?]range%5Byear_.*%5D%5Bbegin%5D=[\d]{1,4}&range%5Byear_.*5D%5Bend%5D=[\d]{1,4}/, '')
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

  def join_as_paragraphs(arg)
    values = arg[:value]
    '<p>'.html_safe + safe_join(values, '</p><p>'.html_safe) + '</p>'.html_safe if values
  end

  def archival_display(arg)
    values = arg[:document][arg[:field]].reverse
    title = link_to arg[:document][:title_tesim] ? arg[:document][:title_tesim].join(", ") : arg[:document][:id], solr_document_path(arg[:document][:id])
    hierarchy = arg[:document][:ancestor_titles_hierarchy_ssim]

    hierarchy_params = (hierarchy_builder arg[:document]).reverse

    if hierarchy.present?
      (0..values.size - 1).each do |i|
        values[i] = link_to values[i], search_catalog_path(hierarchy_params.pop) if hierarchy_params.present?
      end
    end
    if values.count > 5
      values[3] = "<span><button class='show-more-button' aria-label='Show More' title='Show More'>...</button> &gt; </span><span class='show-more-hidden-text'>".html_safe + values[3]
      values[values.count - 2] = "</span></span>".html_safe + values[values.count - 2]
    end
    values << title
    safe_join(values, ' > ')
  end

  def archival_display_show(arg)
    values = arg[:document][arg[:field]].reverse

    hierarchy = arg[:document][:ancestor_titles_hierarchy_ssim]
    hierarchy_params = (hierarchy_builder arg[:document]).reverse

    if hierarchy.present?
      (0..values.size - 1).each do |i|
        values[i] = link_to values[i], search_catalog_path(hierarchy_params.pop) if hierarchy_params.present?
      end
    end
    values << arg[:document][:title_tesim].join(", ") if arg[:document][:title_tesim]
    if values.count > 6
      values[3] = "<span><button class='show-more-button' aria-label='Show More' title='Show More'>...</button> &gt; </span><span class='show-more-hidden-text'>".html_safe + values[3]
      values[values.count - 3] = "</span></span>".html_safe + values[values.count - 3]
    end
    safe_join(values, ' > ')
  end

  def hierarchy_builder(document)
    hierarchy = document[:ancestor_titles_hierarchy_ssim]
    hierarchy_params = [
      { "f[repository_ssi][]" => document[:repository_ssi] },
      { "f[repository_ssi][]" => document[:repository_ssi], "f[collection_title_ssi][]" => document[:collection_title_ssi] }
    ]

    default_params = { "f[repository_ssi][]" => document[:repository_ssi], "f[collection_title_ssi][]" => document[:collection_title_ssi] }

    start_index = 2
    if document[:series_sort_ssi]
      start_index = 3
      params = default_params
      params["f[series_sort_ssi][]"] = document[:series_sort_ssi]
      hierarchy_params << params
    end

    @search_params ||= Hash.new { |h, k| h[k] = h.dup.clear }

    if hierarchy.present? && @search_params
      (start_index..hierarchy.size - 1).each do |i|
        params = default_params.clone
        params["f[ancestor_titles_hierarchy_ssim][]"] = hierarchy[i]
        hierarchy_params << params
      end
    end
    hierarchy_params
  end

  def aspace_link(arg)
    # rubocop:disable Naming/VariableName
    archiveSpaceUri = arg[:document][arg[:field]]
    link = "https://archives.yale.edu#{archiveSpaceUri}"
    popup_window = image_tag("YULPopUpWindow.png", { id: 'popup_window', alt: 'pop up window' })
    link_to 'View item information in Archives at Yale'.html_safe + popup_window, link, target: '_blank', rel: 'noopener'
    # rubocop:enable Naming/VariableName
  end

  def aspace_tree_display(arg)
    ancestor_display_strings = arg[:document][arg[:field]]
    hierarchy_params = hierarchy_builder arg[:document]
    last = ancestor_display_strings.size + 1

    img_home = image_tag("archival_icons/yaleASpaceHome.png", { class: 'ASpace_Home ASpace_Icon', alt: 'Main level' })
    img_stack = image_tag("archival_icons/yaleASpaceStack.png", { class: 'ASpace_Stack ASpace_Icon', alt: 'Second level' })
    img_folder = image_tag("archival_icons/yaleASpaceFolder.png", { class: 'ASpace_Folder ASpace_Icon', alt: 'Document or last level' })
    content_this = tag.span("THIS ITEM", class: ['yaleASpaceItemThis'])

    branch_connection = true
    above_or_below = false
    collapsed = nil
    hierarchy_tree = nil
    ancestor_display_strings.unshift(arg[:document][:title_tesim].first)
    # rubocop:disable Metrics/BlockLength
    (1..last).each do
      current = ancestor_display_strings.shift
      current = if current == arg[:document][:title_tesim].first
                  tag.span(current, class: 'yaleASpaceItemTitle')
                elsif hierarchy_params.present?
                  link_to current, search_catalog_path(hierarchy_params.pop)
                else
                  tag.p(current, class: 'yaleASpaceItem')
                end
      case ancestor_display_strings.size
      when 0
        img = img_home
        li_class = 'yaleASpaceHome'
        ul_class = 'yaleASpaceHomeNested'
        branch_connection = false
      when 1
        img = img_stack
        li_class = 'yaleASpaceStack'
        ul_class = 'yaleASpaceStackNested'
      when last - 1
        img = content_this
        li_class = 'yaleASpaceItemTitle'
        ul_class = 'yaleASpaceItemTitleNested'
      else
        img = img_folder
        li_class = 'yaleASpaceFolder'
        ul_class = 'yaleASpaceFolderNested'
      end
      spacer = tag.span(' ')
      hierarchy_tree = tag.li(class: li_class) do
        tag.div(class: (!(ancestor_display_strings.size < 3 || ancestor_display_strings.size > last - 4) ? 'show-full-tree-hidden-text' : '')) do
          concat tag.span(nil, class: 'aSpaceBranch') if branch_connection
          concat img
          concat spacer if img == content_this
          concat current
          concat collapsed if collapsed && above_or_below
          concat tag.ul(hierarchy_tree, class: ul_class) if hierarchy_tree
        end
      end

      above_or_below = last > 6 && [3, last - 3].include?(ancestor_display_strings.size)
      next unless above_or_below && collapsed.nil?

      collapsed ||= tag.ul do
        tag.li do
          concat tag.span(nil, class: 'aSpaceBranch')
          concat button_tag '...', class: 'show-full-tree-button'
          concat tag.ul(hierarchy_tree)
        end
      end
      above_or_below = false
    end
    # rubocop:enable Metrics/BlockLength
    tag.ul(hierarchy_tree, class: 'aSpace_tree') if hierarchy_tree
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

  def finding_aid_link(arg)
    # rubocop:disable Naming/VariableName
    findingAidUri = arg[:document][arg[:field]]
    links = []
    findingAidUri.each do |link|
      popup_window = image_tag("YULPopUpWindow.png", { id: 'popup_window', alt: 'pop up window' })
      links << link_to(safe_join(['View full finding aid for ',
                                  arg[:document]['collection_title_ssi'].presence || arg[:document]['sourceTitle_tesim'].presence || 'this collection']) + popup_window,
                                  link,
                                  target: '_blank',
                                  rel: 'noopener')
    end
    links.first
  end

  def link_to_url_with_label(arg)
    links = arg[:value].map do |value|
      link_part = value.split('|')
      next unless link_part.count <= 2
      urls = link_part.select { |s| s.start_with? 'http' }
      labels = link_part.select { |s| !s.start_with? 'http' }
      if urls.count == 1
        label = labels[0] || urls[0]
        link_to(label, urls[0])
      end
    end.compact
    safe_join(links, '<br/>'.html_safe)
  end

  def link_to_url(arg)
    link_to(arg[:value][0], arg[:value][0])
  end

  def html_safe_converter(arg)
    value = arg[:value].first
    values = value.split("\n")
    sanitized_values = []
    values.each do |v|
      sanitize v, tags: %w[a], attributes: %w[href]
      sanitized_values << v
    end
    safe_join(sanitized_values, '<br/>'.html_safe)
  end

  def search_field_value_link(args)
    field_value = args[:document][args[:field]]
    link_text = "/?q=#{field_value}&search_field=#{args[:field]}"
    link_to(field_value.join, link_text)
  end

  def sep_title_show_page
    values = @document[:title_tesim]
    safe_join(values, '<br/>'.html_safe) unless values.nil?
  end

  def language_code(args)
    language_value = args
    language_code_to_english(language_value)
  end

  def render_thumbnail(document, _options)
    # return placeholder image if not logged in for yale only works
    return image_tag('placeholder_restricted.png') unless client_can_view_digital?(document)
    url = document[:thumbnail_path_ss]
    if url.present?
      error_image_url = image_url('image_not_found.png')
      return image_tag(url, onerror: "this.error=null;this.src='#{error_image_url}'")
    end
    image_tag('image_not_found.png')
  end

  def pristine_search_state
    Blacklight::SearchState.new(params, blacklight_config)
  end

  def render_schema_org_metadata
    render partial: 'catalog/schema_org_metadata', locals: { metadata: @document.to_schema_json_ld }
  end

  def render_ogp_metadata
    @document.to_ogp_metadata
  end

  def html_tag_attributes
    { lang: I18n.locale, prefix: "og: https://ogp.me/ns#" }
  end

  def fulltext_snippet_separation(options = {})
    # Some snippets come back with new lines embedded without them. We don't want that.
    # We do however want new lines after a snippet, to show separation
    # the "tr" below has to use double quotes, otherwise it will remove the character 'n', instead of new line notations
    snippets_without_new_lines = options[:value].map { |snippet| snippet.tr("\n", ' ') }
    snippets_separated_by_line_break = snippets_without_new_lines.join('<br>')

    simple_format(snippets_separated_by_line_break)
  end

  def strip_order(string)
    pos = string.index('|')
    string = string[pos + 1, string.length - pos - 1] if pos && pos >= 0
    string
  end

  private

  def language_code_to_english(language_code)
    language_name_in_english = ISO_639.find_by_code(language_code)&.english_name
    language_name_in_english.present? ? "#{language_name_in_english} (#{language_code})" : language_code
  end
end
