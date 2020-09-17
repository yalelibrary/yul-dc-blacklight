# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::OriginMetadataPresenter do
  let(:solr_doc) do
    {
      'author_tsim' => 'Author',
      'author_vern_ssim' => 'Author',
      'coordinates_ssim' => 'Coordinates',
      'copyrightDate_ssim' => 'Copyright Date',
      'date_ssim' => 'Date',
      'digital_ssim' => 'Digital',
      'edition_ssim' => 'Edition',
      'language_ssim' => 'Language',
      'publicationPlace_ssim' => 'Publication Place',
      'publisher_ssim' => 'Publisher',
      'published_ssim' => 'Published',
      'published_vern_ssim' => 'Published',
      'sourceCreated_tesim' => 'Source Created',
      'sourceDate_tesim' => 'Source Date',
      'sourceEdition_tesim' => 'Source Edition',
      'sourceNote_tesim' => 'Source Note',
      'sourceTitle_tesim' => 'Source Title'
    }
  end
  let(:presenter_object) { described_class.new(document: solr_doc) }
  let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata/origin_metadata.yml'))) }

  context 'with a solr document containing overview metadata' do
    describe 'config' do
      it 'returns the Author Key' do
        expect(config['author_tsim'].to_s).to eq 'Author'
      end

      it 'returns the Author Key' do
        expect(config['author_vern_ssim'].to_s).to eq 'Author'
      end

      it 'returns the Coordinates Key' do
        expect(config['coordinates_ssim'].to_s).to eq 'Coordinates'
      end

      it 'returns the Copyright Date Key' do
        expect(config['copyrightDate_ssim'].to_s).to eq 'Copyright Date'
      end

      it 'returns the Date Key' do
        expect(config['date_ssim'].to_s).to eq 'Date'
      end

      it 'returns the Digital Key' do
        expect(config['digital_ssim'].to_s).to eq 'Digital'
      end

      it 'returns the Edition Key' do
        expect(config['edition_ssim'].to_s).to eq 'Edition'
      end

      it 'returns the Language Key' do
        expect(config['language_ssim'].to_s).to eq 'Language'
      end

      it 'returns the Publication Place Key' do
        expect(config['publicationPlace_ssim'].to_s).to eq 'Publication Place'
      end

      it 'returns the Publisher Key' do
        expect(config['publisher_ssim'].to_s).to eq 'Publisher'
      end

      it 'returns the Published Key' do
        expect(config['published_ssim'].to_s).to eq 'Published'
      end

      it 'returns the Published Key' do
        expect(config['published_vern_ssim'].to_s).to eq 'Published'
      end

      it 'returns the Source Created Key' do
        expect(config['sourceCreated_tesim'].to_s).to eq 'Source Created'
      end

      it 'returns the Source Date Key' do
        expect(config['sourceDate_tesim'].to_s).to eq 'Source Date'
      end

      it 'returns the Source Edition Key' do
        expect(config['sourceEdition_tesim'].to_s).to eq 'Source Edition'
      end

      it 'returns the Source Note Key' do
        expect(config['sourceNote_tesim'].to_s).to eq 'Source Note'
      end

      it 'returns the Source Title Key' do
        expect(config['sourceTitle_tesim'].to_s).to eq 'Source Title'
      end
    end

    describe "#origin terms" do
      it "are a Hash" do
        expect(presenter_object.origin_terms).to be_instance_of(Hash)
      end
    end
  end
end
