# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::IdentifierMetadataPresenter do
  let(:solr_doc) do
    {
      'box_ssim' => 'Box',
      'children_ssim' => 'Children',
      'collectionId_ssim' => 'Collection ID',
      'findingAid_ssim' => 'Finding Aid',
      'folder_ssim' => 'Folder',
      'identifierMfhd_ssim' => 'Identifier MFHD',
      'identifierShelfMark_ssim' => 'Identifier Shelf Mark',
      'importUrl_ssim' => 'Import URL',
      'isbn_ssim' => 'ISBN',
      'lc_callnum_ssim' => 'Call number',
      'orbisBarcode_ssi' => 'Orbis Bar Code',
      'orbisBibId_ssi' => 'Orbis Bib ID',
      'oid_ssi' => 'OID',
      'partOf_ssim' => 'Collection Name',
      'uri_ssim' => 'URI',
      'url_fulltext_ssim' => 'URL',
      'url_suppl_ssim' => 'More Information'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/identifier_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Box Key' do
        expect(config['box_ssim'].to_s).to eq 'Box'
      end

      it 'returns the Children Key' do
        expect(config['children_ssim'].to_s).to eq 'Children'
      end

      it 'returns the Collection ID Key' do
        expect(config['collectionId_ssim'].to_s).to eq 'Collection ID'
      end

      it 'returns the Finding Aid Key' do
        expect(config['findingAid_ssim'].to_s).to eq 'Finding Aid'
      end

      it 'returns the Folder Key' do
        expect(config['folder_ssim'].to_s).to eq 'Folder'
      end

      it 'returns the Identifier MFHD Key' do
        expect(config['identifierMfhd_ssim'].to_s).to eq 'Identifier MFHD'
      end

      it 'returns the Identifier Shelf Mark Key' do
        expect(config['identifierShelfMark_ssim'].to_s).to eq 'Identifier Shelf Mark'
      end

      it 'returns the Import URL Key' do
        expect(config['importUrl_ssim'].to_s).to eq 'Import URL'
      end

      it 'returns the ISBN Key' do
        expect(config['isbn_ssim'].to_s).to eq 'ISBN'
      end

      it 'returns the Call number Key' do
        expect(config['lc_callnum_ssim'].to_s).to eq 'Call number'
      end

      it 'returns the Orbis Barcode Key' do
        expect(config['orbisBarcode_ssi'].to_s).to eq 'Orbis Bar Code'
      end

      it 'returns the Orbis Bib ID Key' do
        expect(config['orbisBibId_ssi'].to_s).to eq 'Orbis Bib ID'
      end

      it 'returns the OID Key' do
        expect(config['oid_ssi'].to_s).to eq 'OID'
      end

      it 'returns the Collection Name Key' do
        expect(config['partOf_ssim'].to_s).to eq 'Collection Name'
      end

      it 'returns the URI Key' do
        expect(config['uri_ssim'].to_s).to eq 'URI'
      end

      it 'returns the URL Key' do
        expect(config['url_fulltext_ssim'].to_s).to eq 'URL'
      end

      it 'returns the More Information Key' do
        expect(config['url_suppl_ssim'].to_s).to eq 'More Information'
      end
    end

    describe "#identifier terms" do

      it "are a Hash" do
        expect(presenter_object.identifier_terms).to be_instance_of(Hash)
      end
    end
  end
end
