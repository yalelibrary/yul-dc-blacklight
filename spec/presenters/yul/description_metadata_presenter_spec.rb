# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::DescriptionMetadataPresenter do
  let(:solr_doc) do
    {
      'abstract_tesim' => 'Abstract',
      'alternativeTitle_tesim' => 'Alternative Title',
      'description_tesim' => 'Description',
      'extent_ssim' => 'Extent',
      'extentOfDigitization_ssim' => 'Extent of Digitization',
      'numberOfPages_ssim' => 'Number of Pages',
      'illustrativeMatter_tesim' => 'Illustrative Matter',
      'projection_tesim' => 'Projection',
      'references_tesim' => 'References',
      'scale_tesim' => 'Scale',
      'subtitle_tesim' => 'Subtitle'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/description_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Abstract Key' do
        expect(config['abstract_tesim'].to_s).to eq 'Abstract'
      end

      it 'returns the Alternative Title Key' do
        expect(config['alternativeTitle_tesim'].to_s).to eq 'Alternative Title'
      end

      it 'returns the Description Key' do
        expect(config['description_tesim'].to_s).to eq 'Description'
      end

      it 'returns the Extent Key' do
        expect(config['extent_ssim'].to_s).to eq 'Extent'
      end

      it 'returns the Extent of Digitization Key' do
        expect(config['extentOfDigitization_ssim'].to_s).to eq 'Extent of Digitization'
      end

      it 'returns the Number of Pages Key' do
        expect(config['numberOfPages_ssim'].to_s).to eq 'Number of Pages'
      end

      it 'returns the Illustrative Matter Key' do
        expect(config['illustrativeMatter_tesim'].to_s).to eq 'Illustrative Matter'
      end

      it 'returns the Projection Key' do
        expect(config['projection_tesim'].to_s).to eq 'Projection'
      end

      it 'returns the References Key' do
        expect(config['references_tesim'].to_s).to eq 'References'
      end

      it 'returns the Scale Key' do
        expect(config['scale_tesim'].to_s).to eq 'Scale'
      end

      it 'returns the Subtitle Key' do
        expect(config['subtitle_tesim'].to_s).to eq 'Subtitle'
      end
    end

    describe "#description terms" do
      it "are a Hash" do
        expect(presenter_object.description_terms).to be_instance_of(Hash)
      end
    end
  end
end
