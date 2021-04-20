# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength,Metrics/CyclomaticComplexity
module SchemaOrgSolrDocument
  extend ActiveSupport::Concern

  def to_schema_json_ld
    about_description = [self[:subjectTopic_ssim]&.join(", "), self[:subjectGeographic_ssim]&.join(", ")].compact
    about_description = nil if about_description.empty?
    about = {
      "name": self[:subjectName_ssim]&.join(", "),
      "description": about_description&.join(", ")
    }.compact
    about = nil if about.empty?
    {
      "@context": "https://schema.org/",
      "@type": "CreativeWork",
      "name": self[:title_tesim]&.join(", "),
      "alternateName": self[:alternativeTitle_tesim]&.join(", "),
      "description": self[:description_tesim]&.join(", "),
      "url": "https://collections.library.yale.edu/catalog/#{id}",
      "about": about,
      "genre": self[:genre_ssim]&.join(", "),
      "materialExtent": self[:extent_ssim]&.join(", "),
      "temporal": self[:date_ssim]&.join(", "),
      "thumbnailUrl": self[:visibility_ssi] == "Public" && self["thumbnail_path_ss"] || nil
    }.compact
  end
end
