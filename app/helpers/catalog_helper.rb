# frozen_string_literal: true
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

  def client_can_access(document)
    return false unless document.key?('visibility_ssi')
    case document['visibility_ssi']
    when 'Public'
      true
    when 'Yale Community Only'
      return true if current_user || User.on_campus?(request.remote_ip)
      false
    end
  end
end
