# frozen_string_literal: true
# rubocop:disable Metrics/ModuleLength,Metrics/CyclomaticComplexity
module OgpSolrDocument
  extend ActiveSupport::Concern
  include ActionView::Helpers::TagHelper

  def to_ogp_metadata
    description = ogp_description

    ogp_metadata =
      { 'og:title': self[:title_tesim]&.join(', '),
        'og:url': "https://collections.library.yale.edu/catalog/#{id}",
        'og:type': 'website',
        'og:description': description,
        'og:image': self[:visibility_ssi] == "Public" && self["thumbnail_path_ss"] || nil,
        'og:image:type': self[:visibility_ssi] == "Public" && 'image/jpeg' || nil,
        'og:image:secure_url': self[:visibility_ssi] == "Public" && self["thumbnail_path_ss"] || nil }.compact

    meta_tag = []
    ogp_metadata.each do |key, value|
      meta_tag << tag.meta({ property: key, content: value })
    end
    meta_tag
  end

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
