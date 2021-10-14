# frozen_string_literal: true

require "net/http"

module CatalogHelper
  include Blacklight::CatalogHelperBehavior

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

  def remote_file_exists?(given_url)
    url = if given_url.include?('mirador')
            URI.parse((ENV['BLACKLIGHT_BASE_URL']).to_s + given_url)
          else
            URI.parse(given_url)
          end
    Net::HTTP.start(url.host, url.port) do |http|
      return http.head(url.request_uri).code == "200"
    end
  end
end
