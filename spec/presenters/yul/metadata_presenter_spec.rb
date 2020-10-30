# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::MetadataPresenter do
  let(:description_metadata) do
    {
      'abstract_tesim' => 'Abstract',
      'alternativeTitle_tesim' => 'Alternative Title',
      'description_tesim' => 'Description',
      'extent_ssim' => 'Extent',
      'extentOfDigitization_ssim' => 'Extent of Digitization',
      'numberOfPages_ssim' => 'Number of Pages',
      'projection_tesim' => 'Projection',
      'references_tesim' => 'References',
      'scale_tesim' => 'Scale',
      'subtitle_tesim' => 'Subtitle'
    }
  end

  let(:identifier_metadata) do
    {
      'box_ssim' => 'Box',
      'children_ssim' => 'Children',
      'collectionId_ssim' => 'Collection ID',
      'findingAid_ssim' => 'Finding Aid',
      'folder_ssim' => 'Folder',
      'identifierMfhd_ssim' => 'Identifier MFHD',
      'identifierShelfMark_ssim' => 'Call Number',
      'importUrl_ssim' => 'Import URL',
      'isbn_ssim' => 'ISBN',
      'orbisBarcode_ssi' => 'Orbis Bar Code',
      'orbisBibId_ssi' => 'Orbis Bib ID',
      'oid_ssi' => 'OID',
      'partOf_ssim' => 'Collection Name',
      'uri_ssim' => 'URI',
      'url_fulltext_ssim' => 'URL',
      'url_suppl_ssim' => 'More Information'
    }
  end

  let(:keyword_metadata) do
    {
      'format' => 'Format',
      'genre_ssim' => 'Genre',
      'geoSubject_ssim' => 'Subject (Geographic)',
      'material_tesim' => 'Material',
      'resourceType_ssim' => 'Resource Type',
      'subjectName_ssim' => 'Subject (Name)',
      'subjectTopic_tesim' => 'Subject (Topic)'
    }
  end

  let(:migration_source_metadata) do
    {
      'recordType_ssi' => 'Record Type',
      'source_ssim' => 'Source'
    }
  end

  let(:origin_metadata) do
    {
      'creator_tesim' => 'Creator',
      'coordinates_ssim' => 'Coordinates',
      'copyrightDate_ssim' => 'Copyright Date',
      'date_ssim' => 'Date',
      'digital_ssim' => 'Digital',
      'edition_ssim' => 'Edition',
      'language_ssim' => 'Language',
      'publicationPlace_ssim' => 'Publication Place',
      'publisher_ssim' => 'Publisher',
      'published_ssim' => 'Published',
      'sourceCreated_tesim' => 'Source Created',
      'sourceDate_tesim' => 'Source Date',
      'sourceEdition_tesim' => 'Source Edition',
      'sourceNote_tesim' => 'Source Note',
      'sourceTitle_tesim' => 'Source Title'
    }
  end

  let(:usage_metadata) do
    {
      'rights_ssim' => 'Rights'
    }
  end

  context 'with a description document' do
    let(:description_presenter_object) { described_class.new(document: description_metadata, section: 'description') }
    let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'description_metadata.yml'))) }

    context 'containing overview metadata' do
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

      describe 'terms' do
        it 'are a Hash' do
          expect(description_presenter_object.terms).to be_instance_of(Hash)
        end
      end
    end
  end

  context 'with an identifier document' do
    let(:identifier_presenter_object) { described_class.new(document: identifier_metadata, section: 'identifier') }
    let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'identifier_metadata.yml'))) }

    context 'containing overview metadata' do
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

        it 'returns the Call Number Key' do
          expect(config['identifierShelfMark_ssim'].to_s).to eq 'Call Number'
        end

        it 'returns the Import URL Key' do
          expect(config['importUrl_ssim'].to_s).to eq 'Import URL'
        end

        it 'returns the ISBN Key' do
          expect(config['isbn_ssim'].to_s).to eq 'ISBN'
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

      describe 'terms' do
        it 'are a Hash' do
          expect(identifier_presenter_object.terms).to be_instance_of(Hash)
        end
      end
    end
  end

  context 'with a keyword document' do
    let(:keyword_presenter_object) { described_class.new(document: keyword_metadata, section: 'keyword') }
    let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'keyword_metadata.yml'))) }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Format Key' do
          expect(config['format'].to_s).to eq 'Format'
        end

        it 'returns the Genre Key' do
          expect(config['genre_ssim'].to_s).to eq 'Genre'
        end

        it 'returns the Geo Subject Key' do
          expect(config['geoSubject_ssim'].to_s).to eq 'Subject (Geographic)'
        end

        it 'returns the Material Key' do
          expect(config['material_tesim'].to_s).to eq 'Material'
        end

        it 'returns the Resource Type Key' do
          expect(config['resourceType_ssim'].to_s).to eq 'Resource Type'
        end

        it 'returns the Subject Name Key' do
          expect(config['subjectName_ssim'].to_s).to eq 'Subject (Name)'
        end

        it 'returns the Subject Topic Key' do
          expect(config['subjectTopic_tesim'].to_s).to eq 'Subject (Topic)'
        end
      end

      describe 'terms' do
        it 'are a Hash' do
          expect(keyword_presenter_object.terms).to be_instance_of(Hash)
        end
      end
    end
  end

  context 'with a migration source document' do
    let(:migration_source_presenter_object) { described_class.new(document: migration_source_metadata, section: 'migration_source') }
    let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'migration_source_metadata.yml'))) }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Record Type Key' do
          expect(config['recordType_ssi'].to_s).to eq 'Record Type'
        end

        it 'returns the Source Key' do
          expect(config['source_ssim'].to_s).to eq 'Source'
        end
      end

      describe 'terms' do
        it 'are a Hash' do
          expect(migration_source_presenter_object.terms).to be_instance_of(Hash)
        end
      end
    end
  end

  context 'with an origin document' do
    let(:origin_presenter_object) { described_class.new(document: origin_metadata, section: 'origin') }
    let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'origin_metadata.yml'))) }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Creator Key' do
          expect(config['creator_tesim'].to_s).to eq 'Creator'
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

      describe 'terms' do
        it 'are a Hash' do
          expect(origin_presenter_object.terms).to be_instance_of(Hash)
        end
      end
    end
  end

  context 'with a usage document' do
    let(:usage_presenter_object) { described_class.new(document: usage_metadata, section: 'usage') }
    let(:config) { YAML.safe_load(File.open(Rails.root.join('config', 'metadata', 'usage_metadata.yml'))) }

    context 'containing overview metadata' do
      describe 'config' do
        it 'returns the Rights Key' do
          expect(config['rights_ssim'].to_s).to eq 'Rights'
        end
      end

      describe 'terms' do
        it 'are a Hash' do
          expect(usage_presenter_object.terms).to be_instance_of(Hash)
        end
      end
    end
  end
end
