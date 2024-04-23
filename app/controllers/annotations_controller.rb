# frozen_string_literal: true

# Annotations controller used for full text annotation requests
class AnnotationsController < ApplicationController
  include Blacklight::Catalog
  include BlacklightHelper
  include CheckAuthorization
  before_action :check_authorization, only: [:full_text]

  def full_text
    @oid = params[:oid]
    @child_oid = params[:child_oid]
    @response, @child_document = search_service.fetch(@child_oid, { fl: ['fulltext_tesim', 'parent_ssi'] })
    child_doc = @child_document.response['response']['docs'].first
    # byebug
    if child_doc["parent_ssi"] == @oid
      render json: fulltext_response(child_doc["fulltext_tesim"].join('\n'))
    else
      render json: { error: 'unauthorized' }.to_json, status: :unauthorized
    end
  end

  def search_for_item
    # called by CheckAuthorization.  Load parent visibility:
    search_service.fetch(params[:oid], { fl: ['visibility_ssi'] })
  end

  private

  def manifest_base_url
    @manifest_base_url ||= (ENV["IIIF_MANIFESTS_BASE_URL"] || "http://localhost:3000/manifests")
  end

  def fulltext_response(full_text)
    {
      "id": request.original_url,
      "type": "Annotation",
      "motivation": "supplementing",
      "body": {
        "type": "TextualBody",
        "value": full_text
      },
      "target": File.join(manifest_base_url.to_s, "oid/#{@oid}/canvas/#{@child_oid}")
    }
  end
end
