# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::KeywordMetadataPresenter do
  let(:solr_doc) do
    {
      'format' => 'Format',
      'genre_ssim' => 'Genre',
      'geoSubject_ssim' => 'Geo Subject',
      'material_tesim' => 'Material',
      'resourceType_ssim' => 'Resource Type',
      'subjectName_ssim' => 'Subject Name',
      'subjectTopic_ssim' => 'Subject Topic',
      'subjectTopic_tesim' => 'Subject Topic'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/keyword_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Format Key' do
        expect(config['format'].to_s).to eq 'Format'
      end

      it 'returns the Genre Key' do
        expect(config['genre_ssim'].to_s).to eq 'Genre'
      end

      it 'returns the Geo Subject Key' do
        expect(config['geoSubject_ssim'].to_s).to eq 'Geo Subject'
      end

      it 'returns the Material Key' do
        expect(config['material_tesim'].to_s).to eq 'Material'
      end

      it 'returns the Resource Type Key' do
        expect(config['resourceType_ssim'].to_s).to eq 'Resource Type'
      end

      it 'returns the Subject Name Key' do
        expect(config['subjectName_ssim'].to_s).to eq 'Subject Name'
      end

      it 'returns the Subject Topic Key' do
        expect(config['subjectTopic_ssim'].to_s).to eq 'Subject Topic'
      end

      it 'returns the Subject Topic Key' do
        expect(config['subjectTopic_tesim'].to_s).to eq 'Subject Topic'
      end
    end

    describe "#keyword terms" do

      it "are a Hash" do
        expect(presenter_object.keyword_terms).to be_instance_of(Hash)
      end
    end
  end
end
