# frozen_string_literal: true

module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def manifest_url(oid)
    File.join(manifest_base_url, "#{oid}.json")
  end

  def manifest_base_url
    ENV.fetch('IIIF_MANIFESTS_BASE_URL', "#{request.protocol}localhost/manifests")
  end
end
