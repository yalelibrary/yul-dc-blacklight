# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::UsageMetadataPresenter do
  let(:solr_doc) do
    {
      'rights_ssim' => 'Rights'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/usage_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Rights Key' do
        expect(config['rights_ssim'].to_s).to eq 'Rights'
      end
    end

    describe "#usage terms" do

      it "are a Hash" do
        expect(presenter_object.usage_terms).to be_instance_of(Hash)
      end
    end
  end
end
