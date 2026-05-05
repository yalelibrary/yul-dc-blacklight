# frozen_string_literal: true
# Hardens BlacklightOaiProvider so that ListRecords / ListIdentifiers / GetRecord
# only expose records whose visibility is in the catalog UI's metadata-viewable set.
# OAI_ALLOWED_VISIBILITIES MUST stay in sync with AccessHelper#viewable_metadata_visibilities.
# Defense-in-depth: this enforces the policy explicitly, independent of whether the
# Blacklight SearchBuilder processor chain (filter_by_visibility) fires for OAI requests.
#
# Implemented via Module#prepend so that #conditions can call `super` and chain to
# the gem's original implementation instead of replacing it.
module BlacklightOaiProvider
  module OaiVisibilityPatch
    OAI_ALLOWED_VISIBILITIES = ["Public", "Yale Community Only", "Open with Permission"].freeze

    def self.allowed_visibility_fq
      "(" + OAI_ALLOWED_VISIBILITIES.map { |v| "visibility_ssi:\"#{v}\"" }.join(" OR ") + ")"
    end

    def find(selector, options = {})
      return next_set(options[:resumption_token]) if options[:resumption_token]

      if selector == :all
        response = search_service.repository.search(conditions(options))
        return select_partial(BlacklightOaiProvider::ResumptionToken.new(options.merge(last: 0), nil, response.total)) if limit && response.total > limit
        response.documents
      else
        query = search_service.search_builder.where(id: selector).query
        query.append_filter_query(OaiVisibilityPatch.allowed_visibility_fq)
        search_service.repository.search(query).documents.first
      end
    end

    # Defense-in-depth: also enforce on the :all / resumption-token paths,
    # which build their query via the gem's inherited `conditions`.
    def conditions(constraints)
      query = super
      query.append_filter_query(OaiVisibilityPatch.allowed_visibility_fq)
      query
    end
  end

  SolrDocumentWrapper.prepend(OaiVisibilityPatch)
end
