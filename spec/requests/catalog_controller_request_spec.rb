# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "/catalog", clean: true, type: :request do
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY.merge({ "child_oids_ssim": ["5555555"] }) }
  let(:private_work) { WORK_WITH_PRIVATE_VISIBILITY }

  before do
    solr = Blacklight.default_index.connection
    solr.add([public_work, private_work])
    solr.commit
  end

  def ns_hash
    { 'mods' => 'http://www.loc.gov/mods/v3',
      'xlink' => "http://www.w3.org/1999/xlink" }
  end

  describe 'GET /oai?verb=ListRecords&metadataPrefix=oai_mods' do
    it 'returns success to ListRecords' do
      get "/catalog/oai?verb=ListRecords&metadataPrefix=oai_mods"
      expect(response).to have_http_status(:success)
    end

    it 'returns success and data to GetRecord when visibility is not "Private"' do
      get "/catalog/oai?verb=GetRecord&metadataPrefix=oai_mods&identifier=oai:collections.library.yale.edu:#{WORK_WITH_PUBLIC_VISIBILITY[:id]}"
      expect(response).to have_http_status(:success)
      expect(response.body).not_to include "The value of the identifier argument is unknown or illegal in this repository."
    end

    it 'does not return data from GetRecord when visibility is "Private"' do
      get "/catalog/oai?verb=GetRecord&metadataPrefix=oai_mods&identifier=oai:collections.library.yale.edu:#{WORK_WITH_PRIVATE_VISIBILITY[:id]}"
      expect(response.body).to include "The value of the identifier argument is unknown or illegal in this repository."
    end

    it 'returns success to ListFormats' do
      get "/catalog/oai?verb=ListMetadataFormats"
      expect(response).to have_http_status(:success)
    end

    context 'use GetRecord' do
      let(:xml) { Nokogiri::XML(response.body) }
      before do
        get "/catalog/oai?verb=GetRecord&metadataPrefix=oai_mods&identifier=oai:collections.library.yale.edu:#{WORK_WITH_PUBLIC_VISIBILITY[:id]}"
      end

      it 'has xlink ns' do
        node = xml.xpath('//mods:identifier[@type=\'ladybird\']', ns_hash).first
        expect(node.namespaces["xmlns:xlink"]).to eq("http://www.w3.org/1999/xlink")
      end

      it 'returns properly formatted identifier with GetRecord' do
        identifier = xml.xpath('//mods:identifier[@type=\'ladybird\']', ns_hash)
        expect(identifier.text).to eq("oid#{WORK_WITH_PUBLIC_VISIBILITY[:id]}")
      end

      it 'returns properly formatted title with GetRecord' do
        title = xml.xpath('//mods:titleInfo', ns_hash).xpath('//mods:title', ns_hash).first
        expect(title.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:title_tesim].first)
      end

      it 'returns properly formatted abstract_tesim with GetRecord' do
        abstract = xml.xpath('//mods:abstract', ns_hash)
        expect(abstract.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:abstract_tesim].first)
      end

      it 'returns properly formatted accessRestrictions_tesim with GetRecord' do
        access = xml.xpath('//mods:accessCondition', ns_hash).first
        expect(access.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:accessRestrictions_tesim].first)
      end

      it 'returns properly formatted genre_ssim with GetRecord' do
        genre = xml.xpath('//mods:genre', ns_hash).first
        expect(genre.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:genre_ssim].first)
      end

      it 'returns properly formatted description_tesim with GetRecord' do
        note = xml.xpath('//mods:note', ns_hash).first
        expect(note.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:description_tesim].first)
      end

      it 'returns properly formatted callNumber_tesim with GetRecord' do
        classification = xml.xpath('//mods:classification', ns_hash).first
        expect(classification.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:callNumber_ssim].first)
      end

      it 'returns properly formatted repository_tesim with GetRecord' do
        note = xml.xpath('//mods:note[@type=\'preferred citation\']', ns_hash).first
        expect(note.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:repository_ssim].first)
      end

      it 'returns properly formatted caption_tesim with GetRecord' do
        note = xml.xpath('//mods:note[@displayLabel=\'Caption\']', ns_hash).first
        expect(note.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:caption_tesim].first)
      end

      it 'returns properly formatted number_of_pages_ss with GetRecord' do
        note = xml.xpath('//mods:note[@displayLabel=\'number\']', ns_hash)
        expect(note.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:number_of_pages_ss])
      end

      it 'returns properly formatted extentOfDigitization_ssim with GetRecord' do
        note = xml.xpath('//mods:note[@displayLabel=\'Parts scanned\']', ns_hash).first
        expect(note.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:extentOfDigitization_ssim].first)
      end

      it 'returns properly formatted digital_ssim with GetRecord' do
        note = xml.xpath('//mods:note[@displayLabel=\'Digital\']', ns_hash).first
        expect(note.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:digital_ssim].first)
      end

      it 'returns properly formatted format_tesim with GetRecord' do
        format = xml.xpath('//mods:typeOfResource', ns_hash).first
        expect(format.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:format_tesim].first)
      end

      it 'returns properly formatted rights_ssim with GetRecord' do
        rights = xml.xpath('//mods:accessCondition[@type=\'restriction on access\']', ns_hash).first
        expect(rights.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:rights_ssim].first)
      end

      it 'returns properly formatted language_ssim with GetRecord' do
        language = xml.xpath('//mods:language/mods:languageTerm[@type=\'text\']', ns_hash).first
        expect(language.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:language_ssim].first)
      end

      it 'returns properly formatted languageCode_ssim with GetRecord' do
        language = xml.xpath('//mods:language/mods:languageTerm[@type=\'code\']', ns_hash).first
        expect(language.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:languageCode_ssim].first)
      end

      it 'returns properly formatted creatorDisplay_tsim with GetRecord' do
        value = xml.xpath('//mods:name/mods:namePart', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:creatorDisplay_tsim].first)
      end

      it 'returns properly formatted title_tesim with GetRecord' do
        value = xml.xpath('//mods:titleInfo/mods:title', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:title_tesim].first)
      end

      it 'returns properly formatted alternativeTitle_tesim with GetRecord' do
        value = xml.xpath('//mods:titleInfo/mods:alternative', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:alternativeTitle_tesim].first)
      end

      it 'returns properly formatted extent_ssim with GetRecord' do
        value = xml.xpath('//mods:physicalDescription/mods:extent', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:extent_ssim].first)
      end

      it 'returns properly formatted findingAid_ssim with GetRecord' do
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem[@displayLabel=\'Finding Aid\']', ns_hash).attr("href")
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:findingAid_ssim].first)
      end

      it 'returns properly formatted url_suppl_ssim with GetRecord' do
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem[@displayLabel=\'Related Resource\']', ns_hash).attr("href")
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:url_suppl_ssim].first)
      end

      it 'returns properly formatted partOf_tesim with GetRecord' do
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem[@displayLabel=\'Related Exhibition or Resource\']', ns_hash).attr("href")
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:partOf_tesim].first)
      end

      it 'returns properly formatted box_ssim with GetRecord' do # 60
        xml.remove_namespaces!
        value = xml.xpath('//detail [@type=\'Box\']/text', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:box_ssim].first)
      end

      it 'returns properly formatted folder_ssim with GetRecord' do # 61
        xml.remove_namespaces!
        value = xml.xpath('//detail[@type=\'Folder\']/text', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:folder_ssim].first)
      end

      it 'returns properly formatted sourceCreator_tesim with GetRecord' do # 62
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem/name/namePart', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:sourceCreator_tesim].first)
      end

      it 'returns properly formatted sourceTitle_tesim with GetRecord' do # 63
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem/titleInfo/title', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:sourceTitle_tesim].first)
      end

      it 'returns properly formatted sourceCreated_tesim with GetRecord' do # 64 writer.WriteAttributeString
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem/originInfo/place/placeTerm[@type=\'text\']', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:sourceCreated_tesim].first)
      end

      it 'returns properly formatted sourceDate_tesim with GetRecord' do # 66
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem/originInfo/dateCreated', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:sourceDate_tesim].first)
      end

      it 'returns properly formatted sourceEdition_tesim with GetRecord' do # 67
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem/originInfo/edition', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:sourceEdition_tesim].first)
      end

      it 'returns properly formatted sourceNote_tesim with GetRecord' do # 68
        xml.remove_namespaces!
        value = xml.xpath('//relatedItem/note', ns_hash).first
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:sourceNote_tesim].first)
      end

      it 'returns properly formatted edition_ssim with GetRecord' do # 76
        xml.remove_namespaces!
        value = xml.xpath('//originInfo/edition', ns_hash)[1]
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:edition_ssim].first)
      end

      it 'returns properly formatted :creationPlace_ssim with GetRecord' do # 77
        xml.remove_namespaces!
        value = xml.xpath('//originInfo/place/placeTerm[@type=\'text\']', ns_hash)[1]
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:creationPlace_ssim].first)
      end

      it 'returns properly formatted :publisher_ssim with GetRecord' do # 78
        xml.remove_namespaces!
        value = xml.xpath('//originInfo/publisher', ns_hash)
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:publisher_ssim].first)
      end

      it 'returns properly formatted :date_ssim with GetRecord' do # 79
        xml.remove_namespaces!
        value = xml.xpath('//originInfo/dateCreated', ns_hash)[1]
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:date_ssim].first)
      end

      it 'returns properly formatted :subjectName_ssim with GetRecord' do # 88
        xml.remove_namespaces!
        value = xml.xpath('//subject/name[@type=\'personal\']', ns_hash)
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:subjectName_ssim].first)
      end

      it 'returns properly formatted :subjectTopic_ssim with GetRecord' do # 90
        xml.remove_namespaces!
        value = xml.xpath('//subject/topic', ns_hash)
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:subjectTopic_ssim].first)
      end

      it 'returns properly formatted :subjectGeographic_ssim with GetRecord' do # 91
        xml.remove_namespaces!
        value = xml.xpath('//subject/geographic', ns_hash)
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:subjectGeographic_ssim].first)
      end

      it 'returns properly formatted :scale_tesim with GetRecord' do # 95
        xml.remove_namespaces!
        value = xml.xpath('//subject/cartographics/scale', ns_hash)
        expect(value.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:scale_tesim].first)
      end

      it 'returns properly formatted :orbisBidId_ssi with GetRecord' do
        xml.remove_namespaces!
        locator = xml.xpath('//location/holdingSimple/copyInformation/electronicLocator', ns_hash)
        expect(locator.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:orbisBibId_ssi])
      end

      it 'returns properly location object in context' do # 104
        locator = xml.xpath('//mods:location/mods:url[@access=\'object in context\']', ns_hash).attr("href")
        oid = WORK_WITH_PUBLIC_VISIBILITY[:oid_ssi]
        expect(locator.text).to eq("https://collections.library.yale.edu/catalog/#{oid}")
      end

      it 'returns properly formatted :thumbnail_path_ss with GetRecord' do # No fdid
        xml.remove_namespaces!
        url_thumb = xml.xpath('//location/url[@access=\'preview\']', ns_hash).attr("href")
        expect(url_thumb.text).to eq(WORK_WITH_PUBLIC_VISIBILITY[:thumbnail_path_ss])
      end
    end
  end

  describe 'responds to the Blacklight::Exceptions::RecordNotFound exception' do
    it 'redirects to a custom 404 page' do
      params = { id: 'alpha' }
      get "/catalog/#{params[:id]}"

      expect(response.status).to eq(404)
      expect(response.body).to include("The page you were looking for doesn't exist")
      expect(response.body).to include("You may have mistyped the address or provided an invalid Object ID (#{params[:id]})")
    end
  end

  describe 'GET /catalog/<OID>' do
    it 'contains schema.org heading' do
      get "/catalog/#{WORK_WITH_PUBLIC_VISIBILITY[:id]}"

      doc = Nokogiri::HTML::Document.parse(response.body)
      json = doc.css('script[@type=\'application/ld+json\']')&.first&.text
      expect(json).not_to be_nil
      schema = SolrDocument.new(WORK_WITH_PUBLIC_VISIBILITY).to_schema_json_ld&.to_json
      expect(json.strip).to eq(schema)
    end
  end
end
