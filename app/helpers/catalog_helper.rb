# frozen_string_literal: true
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # rubocop:disable Metrics/PerceivedComplexity
  def render_search_to_page_title(params, response = nil)
    constraints = []

    number_of_results = response&.[]('response')&.[]('numFound') || 0

    if params['q'].present?
      q_label = label_for_search_field(params[:search_field]) unless default_search_field && params[:search_field] == default_search_field[:key]

      constraints += if q_label.present?
                       [t('blacklight.search.page_title.results_with_constraint', count: number_of_results, label: q_label, value: params['q'])]
                     else
                       [t('blacklight.search.page_title.results', count: number_of_results, q: params['q'])]
                     end
    end

    constraints += params['f'].to_unsafe_h.collect { |key, value| render_search_to_page_title_filter(key, Array(value)) } if params['f'].present?

    constraints.join(' / ')
  end
  # rubocop:enable Metrics/PerceivedComplexity

  def change_iiif_image_size(url, new_size)
    return nil unless url
    url = URI.parse(url) # e.g. https://collections-test.library.yale.edu/iiif/2/17120080/full/!200,200/0/default.jpg
    path_components = url.path.split("/")
    path_components[5] = new_size
    url.path = path_components.join("/")
    url.to_s
  end

  # Extract fulltext param from search
  # Simple: ...search_field=fulltext_tsim&q=XXX
  # Advanced: fulltext_tsim_advanced=XXX
  def uv_fulltext_search_param
    search_params = current_search_session.try(:query_params) || {}
    q = nil
    if 'fulltext_tesim' == search_params['search_field'] && search_params['q']
      q = search_params['q']
    elsif search_params['fulltext_tsim_advanced']
      q = search_params['fulltext_tsim_advanced']
    end
    "&q=#{url_encode(q)}" if q
  end

  def uv_caption_search_param
    search_params = current_search_session.try(:query_params) || {}
    q = nil
    q = search_params['q'] if search_params['q']
    "&q=#{url_encode(q)}" if q
  end
end
