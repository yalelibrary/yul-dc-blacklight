# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength,Metrics/CyclomaticComplexity
module OgpSolrDocument
  extend ActiveSupport::Concern
  include ActionView::Helpers::TagHelper
  include CatalogHelper

  # rubocop:disable Metrics/PerceivedComplexity
  def to_ogp_metadata
    description = ogp_description

    ogp_metadata =
      { 'og:title': self[:title_tesim]&.join(', '),
        'og:url': "https://collections.library.yale.edu/catalog/#{id}",
        'og:type': 'website',
        'og:description': description,
        'og:image': self[:visibility_ssi] == "Public" && !self[:sensitive_materials_ssi] == "Yes" && change_iiif_image_size(self["thumbnail_path_ss"], '!1200,630') || nil,
        'og:image:type': self[:visibility_ssi] == "Public" && self[:sensitive_materials_ssi] != "Yes" && 'image/jpeg' || nil,
        'og:image:secure_url': self[:visibility_ssi] == "Public" && self[:sensitive_materials_ssi] != "Yes" && change_iiif_image_size(self["thumbnail_path_ss"], '!1200,630') || nil }.compact

    meta_tag = []
    ogp_metadata.each do |key, value|
      meta_tag << tag.meta(property: key, content: value)
    end
    meta_tag
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  def ogp_description
    description_value = []
    description_value += self[:alternativeTitle_tesim] if self[:alternativeTitle_tesim]
    description_value += self[:creator_tesim] if self[:creator_tesim]
    description_value += self[:date_ssim] if self[:date_ssim]
    description_value.compact!
    !description_value.empty? && description_value.join('; ') || nil
  end
end
