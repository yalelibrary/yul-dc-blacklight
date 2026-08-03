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
    sanitize_metadata(
      "@context": "https://schema.org/",
      "@type": "CreativeWork",
      "name": self[:title_tesim],
      "alternateName": self[:alternativeTitle_tesim],
      "description": self[:description_tesim],
      "about": about,
      "genre": self[:genre_ssim],
      "materialExtent": self[:extent_ssim],
      "temporal": self[:date_ssim]
    ).merge(
      "url": "https://collections.library.yale.edu/catalog/#{id}",
      "thumbnailUrl": self[:visibility_ssi] == "Public" && self["thumbnail_path_ss"] || nil
    ).compact
  end
  # rubocop:enable Metrics/PerceivedComplexity

  private

  ALLOWED_TAGS = %w[a].freeze
  ALLOWED_ATTRIBUTES = %w[href].freeze

  # JSON-LD values are consumed as plain text, but Solr values may carry markup.
  def sanitize_metadata(value)
    case value
    when Hash then value.transform_values { |v| sanitize_metadata(v) }
    when Array then value.map { |v| sanitize_metadata(v) }
    when String then sanitize_metadata_string(value)
    else value
    end
  end

  # :prune drops script/style/comments with their contents; :strip would leave the script
  # body behind as text. `sanitize` then reduces the rest to the allowlist, keeping the
  # inner text of tags like <em>. Decoding last undoes the entity escaping `sanitize`
  # applies to the text it keeps, which would otherwise publish `&` as `&amp;`.
  def sanitize_metadata_string(value)
    pruned = Loofah.html5_fragment(value).scrub!(:prune).to_html
    ActionController::Base.helpers.sanitize(pruned, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
                          .then { |allowed| CGI.unescapeHTML(allowed).strip }
  end
end
