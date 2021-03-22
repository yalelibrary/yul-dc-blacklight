# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "/catalog", clean: true, type: :request do
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({ "child_oids_ssim": ["5555555"] }) }

  before do
    solr = Blacklight.default_index.connection
    solr.add([public_work])
    solr.commit
  end

  def ns_hash
    { 'mods' => 'http://www.loc.gov/mods/v3' }
  end

  describe 'GET /oai?verb=ListRecords&metadataPrefix=oai_mods' do
    it 'returns success to ListRecords' do
      get "/catalog/oai?verb=ListRecords&metadataPrefix=oai_mods"
      expect(response).to have_http_status(:success)
    end

    it 'returns success to GetRecord' do
      get "/catalog/oai?verb=GetRecord&metadataPrefix=oai_mods&identifier=oai:collections.library.yale.edu:#{WORK_WITH_PUBLIC_VISIBILITY[:id]}"
      expect(response).to have_http_status(:success)
    end

    it 'returns success to ListFormats' do
      get "/catalog/oai?verb=ListMetadataFormats"
      expect(response).to have_http_status(:success)
    end

    it 'returns properly formatted identifier with GetRecord' do
      get "/catalog/oai?verb=GetRecord&metadataPrefix=oai_mods&identifier=oai:collections.library.yale.edu:#{WORK_WITH_PUBLIC_VISIBILITY[:id]}"
      expect(response).to have_http_status(:success)
      xml = Nokogiri::XML(response.body)
      identifier = xml.xpath('//mods:identifier[@type=\'ladybird\']', ns_hash)
      expect(identifier.text).to eq("oid#{WORK_WITH_PUBLIC_VISIBILITY[:id]}")
    end

    it 'returns properly formatted title with GetRecord' do
      get "/catalog/oai?verb=GetRecord&metadataPrefix=oai_mods&identifier=oai:collections.library.yale.edu:#{WORK_WITH_PUBLIC_VISIBILITY[:id]}"
      expect(response).to have_http_status(:success)
      xml = Nokogiri::XML(response.body)
      title = xml.xpath('//mods:titleInfo', ns_hash).xpath('//mods:title', ns_hash)
      expect(title.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:title_tesim].first)
    end
  end
end
