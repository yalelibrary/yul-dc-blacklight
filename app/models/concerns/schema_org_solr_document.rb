# frozen_string_literal: true

# rubocop:disable Metrics/ModuleLength,Metrics/CyclomaticComplexity
module SchemaOrgSolrDocument
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/PerceivedComplexity
  def to_schema_json_ld
    about_names = []
    about_names += self[:subjectName_ssim] if self[:subjectName_ssim]
    about_names += self[:subjectTopic_ssim] if self[:subjectTopic_ssim]
    about_names += self[:subjectGeographic_ssim] if self[:subjectGeographic_ssim]
    about_names.compact!
    about = about_names.map { |name| { "@type": "Thing", name: name } } unless about_names.empty?
    {
      "@context": "https://schema.org/",
      "@type": "CreativeWork",
      "name": self[:title_tesim],
      "alternateName": self[:alternativeTitle_tesim],
      "description": self[:description_tesim],
      "url": "https://collections.library.yale.edu/catalog/#{id}",
      "about": about,
      "genre": self[:genre_ssim],
      "materialExtent": self[:extent_ssim],
      "temporal": self[:date_ssim],
      "thumbnailUrl": self[:visibility_ssi] == "Public" && self[:sensitive_materials_ssi] != "Yes" && self["thumbnail_path_ss"] || nil
    }.compact
  end
  # rubocop:enable Metrics/PerceivedComplexity
end
