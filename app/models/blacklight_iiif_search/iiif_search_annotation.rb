# frozen_string_literal: true

# corresponds to IIIF Annotation resource
module BlacklightIiifSearch
  class IiifSearchAnnotation
    include IIIF::Presentation
    include BlacklightIiifSearch::AnnotationBehavior

    attr_reader :document, :query, :hl_index, :snippet, :controller,
                :parent_document

    ##
    # @param [SolrDocument] document
    # @param [String] query
    # @param [Integer] hl_index
    # @param [String] snippet
    # @param [CatalogController] controller
    # @param [SolrDocument] parent_document
    # rubocop:disable Metrics/ParameterLists
    def initialize(document, query, hl_index, snippet, controller, parent_document)
      @document = document
      @query = query
      @hl_index = hl_index
      @snippet = snippet
      @controller = controller
      @parent_document = parent_document
    end
    # rubocop:enable Metrics/ParameterLists

    ##
    # @return [IIIF::Presentation::Annotation]
    def as_hash
      annotation = IIIF::Presentation::Annotation.new('@id' => annotation_id)
      #  Overriding default behaviour to always have a resource, even if there is no snippet.
      #  Universal Viewer expects that all result annotations have resources, so if there is no snippet, still create
      #  one using the query itself as the snippet.
      #  (Manifold, used by UV, has the problem here:
      #   https://github.com/IIIF-Commons/manifold/blob/v2.0.3/src/AnnotationRect.ts#L19
      #   when this.resource is null)
      annotation.resource = text_resource_for_annotation(snippet || query)
      annotation['on'] = canvas_uri_for_annotation
      annotation
    end

    ##
    # @return [IIIF::Presentation::Resource]
    def text_resource_for_annotation(snippet)
      clean_snippet = ActionView::Base.full_sanitizer.sanitize(snippet)
      IIIF::Presentation::Resource.new('@type' => 'cnt:ContentAsText',
                                       'chars' => clean_snippet)
    end
  end
end
