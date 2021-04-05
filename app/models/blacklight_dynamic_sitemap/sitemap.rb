# frozen_string_literal: true
#
module BlacklightDynamicSitemap
  ##
  #
  class Sitemap
    delegate :hashed_id_field, :unique_id_field, :last_modified_field, to: :engine_config
    include AccessHelper

    def get(id)
      # if someone's hacking URLs (in ways that could potentially generate enormous requests),
      # just return an empty response
      return [] if id.length != exponent
      fq = viewable_metadata_visibilities.map { |visibility| "(visibility_ssi:\"#{visibility}\")" }.join(" OR ")
      index_connection.select(
        params: show_params(id, {
                              q: '*:*',
                              fq: ["{!prefix f=#{hashed_id_field} v=#{id}}", fq],
                              fl: [unique_id_field, last_modified_field, 'visibility_ssi', 'thumbnail_path_ss'].join(','),
                              rows: 2_000_000, # Ensure that we do not page this result
                              facet: false,
                              defType: 'lucene'
                            })
      ).dig('response', 'docs')
    end

    def list
      access_list
    end

    private

    def show_params(id, default_params)
      engine_config.modify_show_params&.call(id, default_params) || default_params
    end

    def index_params(default_params)
      engine_config.modify_index_params&.call(default_params) || default_params
    end

    def index_connection
      @index_connection ||= Blacklight.default_index.connection
    end

    def engine_config
      BlacklightDynamicSitemap::Engine.config
    end

    def max_documents
      key = 'blacklight_dynamic_sitemap.index_max_docs'
      expiration = engine_config.max_documents_expiration
      Rails.cache.fetch(key, expires_in: expiration) do
        index_connection.select(
          params: index_params({ q: '*:*', rows: 0, facet: false })
        )['response']['numFound']
      end
    end

    def average_chunk
      [engine_config.minimum_average_chunk, max_documents].min # Sufficiently less than 50,000 max per sitemap
    end

    ##
    # Exponent used to calculate the needed number of prefix spaces to query
    # that will effectively chunk the entire number of documents. 16 is the
    # number of characters in hex space (0-9, a-f)
    # Example: 16**1 = 16, 16**2 = 256, 16**3 = 4096
    # x = b**y
    # y = logb(x)
    # y = logb(x) = ln(x) / ln(b)
    def exponent
      @exponent ||= [
        (Math.log(max_documents / average_chunk) / Math.log(16)).ceil,
        1
      ].max
    end

    ##
    # Expand the number of documents used off of calculated exponent to create
    # list of sitemaps to access in hex space (0-9, a-f)
    # Example: (exponent as 4)
    # ["0000", "0001", "0002", "0003"..."af74", "af75", "af76", "af77"..."fffc", "fffd", "fffe", "ffff"]
    def access_list
      (0...(16**exponent))
        .to_a
        .map { |v| v.to_s(16).rjust(exponent, '0') }
    end
  end
end
