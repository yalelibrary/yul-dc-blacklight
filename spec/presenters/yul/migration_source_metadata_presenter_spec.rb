# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::MigrationSourceMetadataPresenter do
  let(:solr_doc) do
    {
      'recordType_ssi' => 'Record Type',
      'source_ssim' => 'Source'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/migration_source_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Record Type Key' do
        expect(config['recordType_ssi'].to_s).to eq 'Record Type'
      end

      it 'returns the Source Key' do
        expect(config['source_ssim'].to_s).to eq 'Source'
      end
    end

    describe "#migration_source terms" do
      it "are a Hash" do
        expect(presenter_object.migration_source_terms).to be_instance_of(Hash)
      end
    end
  end
end
