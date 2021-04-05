# frozen_string_literal: true

xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset(
  'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
  'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd',
  'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9'
) do
  config = BlacklightDynamicSitemap::Engine.config
  @sitemap_entries.each do |doc|
    xml.url do
      xml.loc(main_app.solr_document_url(doc[config.unique_id_field]))
      last_modified = doc[config.last_modified_field]
      xml.lastmod(config.format_last_modified&.call(last_modified) || last_modified)
      xml.image doc['thumbnail_path_ss'] if doc['visibility_ssi'] == "Public" && doc['thumbnail_path_ss']
    end
  end
end
