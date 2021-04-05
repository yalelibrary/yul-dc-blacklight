# frozen_string_literal: true
module BlacklightOaiProvider
  class SolrDocumentWrapper < ::OAI::Provider::Model
    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = search_service.repository.search(conditions(options))

        return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total)) if limit && response.total > limit
        response.documents
      else
        # search_service.fetch(selector).first.documents.first
        query = search_service.search_builder.where(id: selector).query
        search_service.repository.search(query).documents.first
      end
    end
  end
end
