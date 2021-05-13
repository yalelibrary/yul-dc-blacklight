# frozen_string_literal: true

# customizable behavior for IiifSearchAnnotation
module BlacklightIiifSearch
  module AnnotationBehavior
    ##
    # Create a URL for the annotation
    # @return [String]
    def annotation_id
      "#{controller.solr_document_url(parent_document[:id])}/canvas/#{document[:id]}/annotation/#{hl_index}"
    end

    def manifest_base_url
      @manifest_base_url ||= (ENV["IIIF_MANIFESTS_BASE_URL"] || "http://localhost/manifests")
    end

    ##
    # Create a URL for the canvas that the annotation refers to
    # @return [String]
    def canvas_uri_for_annotation
      "#{manifest_base_url}oid/#{document[:parent_ssi]}/canvas/#{document[:id]}" + coordinates
    end

    ##
    # return a string like "#xywh=100,100,250,20"
    # corresponding to coordinates of query term on image
    # local implementation expected, value returned below is just a placeholder
    # @return [String]
    def coordinates
      return '' unless query
      '#xywh=0,0,0,0'
    end
  end
end
